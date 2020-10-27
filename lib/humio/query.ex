defmodule Humio.Query do
  @moduledoc """
  Sync functions to query Humio Search results
  """
  alias Humio.{Client, Runner, State}

  @spec query(Humio.Client.t(), String.t(), State.maybe_time(), State.maybe_time(), keyword) ::
          {:ok, [any], Humio.State.t()}
  def query(%Client{} = client, query_string, start_time, end_time \\ nil, opts \\ []) do
    opts =
      opts
      |> Keyword.delete(:live?)
      |> Keyword.put_new(:live?, false)

    %State{
      client: client,
      query_string: query_string,
      start_time: start_time,
      end_time: end_time,
      opts: opts
    }
    |> Runner.start()
    |> Humio.Stream.to_query()
  end

  @spec query_values(
          Humio.Client.t(),
          binary,
          nil | binary | number,
          nil | binary | number,
          keyword
        ) ::
          [any]
  def query_values(%Client{} = client, query_string, start_time, end_time \\ nil, opts \\ []) do
    opts =
      opts
      |> Keyword.delete(:live?)
      |> Keyword.put_new(:live?, false)

    %State{
      client: client,
      query_string: query_string,
      start_time: start_time,
      end_time: end_time,
      opts: opts
    }
    |> Runner.start()
    |> Enum.map(fn %{value: event} ->
      event
    end)
  end
end
