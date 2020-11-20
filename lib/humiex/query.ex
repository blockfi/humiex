defmodule Humiex.Query do
  @moduledoc """
  Sync functions to query Humiex Search results
  """
  alias Humiex.{Client, Runner, State}

  @spec query(Humiex.Client.t(), String.t(), State.maybe_time(), State.maybe_time(), keyword) ::
          {:ok, [any], Humiex.State.t()} | {:error, any, Humiex.State.t()}
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
    |> Humiex.Stream.to_query()
  end

  @spec query_values(
          Humiex.Client.t(),
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
    |> Enum.map(fn
      {:error, _info, _state} = error ->
        error

      %{value: event} ->
        event
    end)
  end
end
