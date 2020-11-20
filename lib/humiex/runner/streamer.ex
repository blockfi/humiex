defmodule Humiex.Runner.Streamer do
  @moduledoc false
  require Logger
  alias Humiex.{State, Client}

  @spec start(Humiex.State.t()) :: Enumerable.t()
  def start(%State{client: %Client{http_client: http_client}} = state) do
    start_fun = http_client.start(state)

    Stream.resource(
      start_fun,
      &http_client.next/1,
      &http_client.stop/1
    )
    |> lines()
  end

  defp update_from_events(events, state) do
    Enum.reduce(
      events,
      {[], state},
      fn %{"@id" => event_id, "@timestamp" => event_timestamp} = event, {acc_events, acc_state} ->
        %State{
          last_timestamp: last_timestamp,
          latest_ids: latest_ids,
          event_count: event_count
        } = acc_state

        new_count = event_count + 1

        new_state =
          cond do
            event_timestamp > last_timestamp ->
              ids = [event_id]

              %State{
                acc_state
                | last_timestamp: event_timestamp,
                  latest_ids: ids,
                  event_count: new_count,
                  chunk: nil
              }

            event_timestamp == last_timestamp ->
              ids = [event_id | latest_ids]

              %State{
                acc_state
                | last_timestamp: event_timestamp,
                  latest_ids: ids,
                  event_count: new_count,
                  chunk: nil
              }

            true ->
              %State{
                acc_state
                | event_count: new_count,
                  chunk: nil
              }
          end

        updated_events = acc_events ++ [%{value: event, state: new_state}]
        {updated_events, new_state}
      end
    )
  end

  def lines(enum), do: lines(enum, :string_split)

  defp lines(enum, :string_split) do
    enum
    |> Stream.transform("", fn
      %State{chunk: chunk, status: :ok}, {prev_line, prev_state} ->
        [last_line | lines] =
          (prev_line <> chunk)
          |> String.split("\n")
          |> Enum.reverse()

        events = lines |> Enum.map(&Jason.decode!/1) |> Enum.reverse()
        {enriched_events, new_state} = update_from_events(events, prev_state)

        {enriched_events, {last_line, new_state}}

      %State{chunk: chunk, status: :ok} = initial_state, acc ->
        [last_line | lines] =
          (acc <> chunk)
          |> String.split("\n")
          |> Enum.reverse()

        events = lines |> Enum.map(&Jason.decode!/1) |> Enum.reverse()
        {enriched_events, new_state} = update_from_events(events, initial_state)
        {enriched_events, {last_line, new_state}}

      %State{status: :error, response_code: code, chunk: message} = state, _acc ->
        {[{:error, %{code: code, message: message}, state}], state}
    end)
  end
end
