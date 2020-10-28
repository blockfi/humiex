defmodule Humiex.Runner.HTTPClient do
  @moduledoc false
  @behaviour Humiex.HTTPAsyncBehaviour

  require Logger
  alias Humiex.{Client, State}

  @default_live_config true
  @default_recv_timeout 5_000

  defp to_body(%State{
         query_string: query_string,
         start_time: start_time,
         end_time: end_time,
         opts: opts
       }) do
    live? = Keyword.get(opts, :live?, @default_live_config)

    %{}
    |> Map.put("queryString", query_string)
    |> Map.put("start", start_time)
    |> Map.put("end", end_time)
    |> Map.put("isLive", live?)
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
    |> Jason.encode!()
  end

  @impl true
  def start(%State{client: %Client{url: url, headers: headers}} = state) do
    fn ->
      body = to_body(state)
      resp = HTTPoison.post!(url, body, headers, stream_to: self(), async: :once)

      %State{
        state
        | resp: resp,
          last_timestamp: 0,
          latest_ids: [],
          event_count: 0
      }
    end
  end

  @impl true
  def stop(%State{resp: %HTTPoison.AsyncResponse{id: id}}) do
    :hackney.stop_async(id)
  end

  @impl true
  def next(
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
end
