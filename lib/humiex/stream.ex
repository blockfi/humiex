defmodule Humiex.Stream do
  @moduledoc """
  Async functions to Stream Humiex Search results
  """
  alias Humiex.{Client, Runner, State}
  require Logger

  @spec stream(Humiex.Client.t(), String.t(), State.maybe_time(), keyword) :: Enumerable.t()
  def stream(client, query_string, start_time \\ nil, opts \\ [])

  def stream(%Client{} = _client, _query_string, start_time, _opts) when is_number(start_time) do
    {:error, "Live queries can only use relative time as a start"}
  end

  def stream(%Client{} = client, query_string, start_time, opts)
      when is_bitstring(query_string) do
    opts =
      opts
      |> Keyword.delete(:live?)
      |> Keyword.put_new(:live?, true)

    %State{
      client: client,
      query_string: query_string,
      start_time: start_time,
      end_time: "now",
      opts: opts
    }
    |> Runner.start()
  end

  def stream(
        %State{latest_ids: [], last_timestamp: nil} = state
      ) do
    state |> inspect() |> Logger.debug()
    %State{state | start_time: nil, end_time: "now"}
    |> Runner.start()
  end
  def stream(
        %State{query_string: query_string, latest_ids: ids, last_timestamp: timestamp} = state
      ) do
    ids =
      ids
      |> Enum.join(", ")

    query_string =
      query_string <>
        " | @timestamp>=#{timestamp} | @id =~ !in(values=[#{ids}])"

    %State{state | query_string: query_string, start_time: nil, end_time: "now"}
    |> Runner.start()
  end

  @spec stream_values(Humiex.Client.t(), String.t(), State.maybe_time(), keyword) :: Enumerable.t()
  def stream_values(client, query_string, start_time \\ nil, opts \\ [state_dest: self()])

  def stream_values(%Client{} = _client, _query_string, start_time, _opts)
      when is_number(start_time) do
    {:error, "Live queries can only use relative time as a start"}
  end

  def stream_values(%Client{} = client, query_string, start_time, opts) do
    opts =
      opts
      |> Keyword.update(:state_dest, self(), fn existing -> existing end)

    state_dest = opts[:state_dest]

    client
    |> stream(query_string, start_time, opts)
    |> Stream.map(fn
      {:error, _info, _state} = error ->
        error
      %{value: value, state: state} ->
      send(state_dest, {:updated_humio_query_state, state})
      value
    end)
  end

  @spec stream_values(Humiex.State.t()) :: Enumerable.t()
  def stream_values(%State{opts: opts} = state) do
    state_dest = Keyword.get(opts, :state_dest, self())

    state
    |> stream()
    |> Stream.map(fn
      {:error, _info, _state} = error ->
        error
      %{value: value, state: state} ->
        send(state_dest, {:updated_humio_query_state, state})
        value
    end)
  end

  @spec to_query(Enumerable.t()) :: {:ok, [any], Humiex.State.t()}
  def to_query(stream) do
    stream
    |> Enum.reduce({:ok, [], nil}, fn
      {:error, _info, _state} = error, _ ->
        error
      %{value: value, state: state}, {:ok, events, _state} ->
      {:ok, [value | events], state}
    end)
  end
end
