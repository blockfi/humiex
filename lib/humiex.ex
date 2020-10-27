defmodule Humiex do
  @moduledoc """
  Functions to query and stream requests using Humiex search API

  """

  @type relative_time() :: Humiex.State.relative_time()
  @type time() :: Humiex.State.time()
  @type maybe_time() :: Humiex.State.maybe_time()

  @spec query(Humiex.Client.t(), String.t(), maybe_time(), maybe_time(), keyword) ::
          {:ok, [any], Humiex.State.t()} | {:error, any}
  defdelegate query(client, query_string, start_time, end_time \\ nil, opts \\ []),
    to: Humiex.Query

  @spec query_values(Humiex.Client.t(), String.t(), maybe_time(), maybe_time(), keyword) :: [any]
  defdelegate query_values(client, query_string, start_time, end_time \\ nil, opts \\ []),
    to: Humiex.Query

  @spec stream(Humiex.Client.t(), String.t(), relative_time(), keyword) :: Enumerable.t()
  defdelegate stream(client, query_string, start_time, opts \\ []), to: Humiex.Stream

  @spec stream_values(Humiex.Client.t(), String.t(), maybe_time(), keyword) :: Enumerable.t()
  defdelegate stream_values(client, query_string, start_time, opts \\ []), to: Humiex.Stream

  @spec stream(Humiex.State.t()) :: Enumerable.t()
  defdelegate stream(state), to: Humiex.Stream

  @spec stream_values(Humiex.State.t()) :: Enumerable.t()
  defdelegate stream_values(state), to: Humiex.Stream
end
