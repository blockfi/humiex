defmodule Humiex do
  @moduledoc """
  Functions to query and stream requests using Humiex search API

  """

  @type relative_time() :: Humiex.State.relative_time()
  @type time() :: Humiex.State.time()
  @type maybe_time() :: Humiex.State.maybe_time()

  @doc """
  Makes a search request to the Humio API and returns the events and state synchronously

  Takes a Humiex.Client configuration, Query String, Start Time, End Time and optionally options

  ## examples
      iex> client = Humiex.Client.new("my-humio-host.com", "my_repo", "my_token")
      iex> query_string = "#env=dev #type=log foo"

      iex> relative_start = "1s"
      iex> {:ok, relative_events, relative_state} = Humiex.query(client, query_string, relative_start)

      iex> absolute_start = 1604447249
      iex> {:ok, absolute_events, absolute_state} = Humiex.query(client, query_string, absolute_start)
  """
  @spec query(Humiex.Client.t(), String.t(), maybe_time(), maybe_time(), keyword) ::
          {:ok, [any], Humiex.State.t()} | {:error, any}
  defdelegate query(client, query_string, start_time, end_time \\ nil, opts \\ []),
    to: Humiex.Query

  @doc """
  Makes a search request to the Humio API and synchronously returns only the events

  Takes a Humiex.Client configuration, Query String, Start Time, End Time and optionally options

  ## examples
      iex> client = Humiex.Client.new("my-humio-host.com", "my_repo", "my_token")
      iex> query_string = "#env=dev #type=log foo"

      iex> relative_start = "1s"
      iex> relative_events = Humiex.query_values(client, query_string, relative_start)

      iex> absolute_start = 1604447249
      iex> absolute_events = Humiex.query_values(client, query_string, absolute_start)
  """
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
