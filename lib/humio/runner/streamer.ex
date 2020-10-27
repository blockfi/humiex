defmodule Humio.Runner.Streamer do
  @moduledoc false
  require Logger
  alias Humio.State
  alias Humio.Runner.HTTPClient

  @default_recv_timeout 5_000

  @spec start(Humio.State.t()) :: Enumerable.t()
  def start(%State{} = state) do
    start_fun = HTTPClient.post(state)

    Stream.resource(
      start_fun,
      &next_fun/1,
      &HTTPClient.end_fun/1
    )
  end

  def next_fun(
         %State{
           resp: %HTTPoison.AsyncResponse{id: id} = resp,
           opts: opts
         } = state
       ) do
    recv_timeout = Keyword.get(opts, :recv_timeout, @default_recv_timeout)

    receive do
      %HTTPoison.AsyncStatus{id: ^id, code: code} ->
        Logger.debug("STATUS: #{code}")
        HTTPoison.stream_next(resp)
        {[], state}

      %HTTPoison.AsyncHeaders{id: ^id, headers: headers} ->
        Logger.debug("RESPONSE HEADERS: #{inspect(headers)}")
        HTTPoison.stream_next(resp)
        {[], state}

      %HTTPoison.AsyncChunk{id: ^id, chunk: chunk} ->
        HTTPoison.stream_next(resp)
        # :erlang.garbage_collect()
        new_state = %State{state | chunk: chunk}
        {[new_state], new_state}

      %HTTPoison.AsyncEnd{id: ^id} ->
        {:halt, state}
    after
      recv_timeout -> raise "receive timeout"
    end
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
      %State{chunk: chunk}, {prev_line, prev_state} ->
        [last_line | lines] =
          (prev_line <> chunk)
          |> String.split("\n")
          |> Enum.reverse()

        events = lines |> Enum.map(&Jason.decode!/1) |> Enum.reverse()
        {enriched_events, new_state} = update_from_events(events, prev_state)

        {enriched_events, {last_line, new_state}}

      %State{chunk: chunk} = initial_state, acc ->
        [last_line | lines] =
          (acc <> chunk)
          |> String.split("\n")
          |> Enum.reverse()

        events = lines |> Enum.map(&Jason.decode!/1) |> Enum.reverse()
        {enriched_events, new_state} = update_from_events(events, initial_state)
        {enriched_events, {last_line, new_state}}
    end)
  end
end
