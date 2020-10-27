defmodule Humio do
  @moduledoc """
  Functions to query and stream requests using Humio search API

  """

  @type relative_time() :: Humio.State.relative_time()
  @type time() :: Humio.State.time()
  @type maybe_time() :: Humio.State.maybe_time()

  @spec query(Humio.Client.t(), String.t(), maybe_time(), maybe_time(), keyword) ::
          {:ok, [any], Humio.State.t()} | {:error, any}
  defdelegate query(client, query_string, start_time, end_time \\ nil, opts \\ []),
    to: Humio.Query

  @spec query_values(Humio.Client.t(), String.t(), maybe_time(), maybe_time(), keyword) :: [any]
  defdelegate query_values(client, query_string, start_time, end_time \\ nil, opts \\ []),
    to: Humio.Query

  @spec stream(Humio.Client.t(), String.t(), relative_time(), keyword) :: Enumerable.t()
  defdelegate stream(client, query_string, start_time, opts \\ []), to: Humio.Stream

  @spec stream_values(Humio.Client.t(), String.t(), maybe_time(), keyword) :: Enumerable.t()
  defdelegate stream_values(client, query_string, start_time, opts \\ []), to: Humio.Stream

  @spec stream(Humio.State.t()) :: Enumerable.t()
  defdelegate stream(state), to: Humio.Stream

  @spec stream_values(Humio.State.t()) :: Enumerable.t()
  defdelegate stream_values(state), to: Humio.Stream
end
