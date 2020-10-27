defmodule Humio.Runner.HTTPClient do
  @moduledoc false

  require Logger
  alias Humio.{Client, State}

  @default_live_config true

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

  def post(%State{client: %Client{url: url, headers: headers}} = state) do
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

  def end_fun(%State{resp: %HTTPoison.AsyncResponse{id: id}}) do
    :hackney.stop_async(id)
  end
end
