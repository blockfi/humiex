defmodule Humiex do
  @moduledoc """
  Functions to query and stream requests using Humiex search API

  """

  @type relative_time() :: Humiex.State.relative_time()
  @type time() :: Humiex.State.time()
  @type maybe_time() :: Humiex.State.maybe_time()

  @doc """
  Creates a new Humiex.Client

  Takes a Hostname, Repository Name, Token and options

  ## example
      iex> client = Humiex.new_client("https://my-humio-host.com", "my_repo", "my_token")
      %Humiex.Client{
      headers: [
        {"authorization", "Bearer my_token"},
        {"Content-Type", "application/json"},
        {"Accept", "application/x-ndjson"}
      ],
      http_client: Humiex.Runner.HTTPClient,
      repo: "my_repo",
      token: "my_token",
      url: "https://my-humio-host.com/api/v1/repositories/my_repo/query"
      }
  """
  @spec new_client(binary, any, any, keyword) :: Humiex.Client.t()
  defdelegate new_client(host, repo, token, opts \\ []), to: Humiex.Client, as: :new

  @doc """
  Makes a search request to the Humio API and returns the events and state synchronously

  Takes a Humiex.Client configuration, Query String, Start Time, End Time and options

  ## examples
      iex> client = Humiex.new_client("https://my-humio-host.com", "my_repo", "my_token")
      iex> query_string = "#env=dev #type=log foo"

      iex> relative_start = "1s"
      iex> {:ok, relative_events, relative_state} = Humiex.query(client, query_string, relative_start)

      iex> absolute_start = 1604447249
      iex> {:ok, absolute_events, absolute_state} = Humiex.query(client, query_string, absolute_start)
  """
  @spec query(Humiex.Client.t(), String.t(), maybe_time(), maybe_time(), keyword) ::
          {:ok, [any], Humiex.State.t()} | {:error, any, Humiex.State.t()}
  defdelegate query(client, query_string, start_time, end_time \\ nil, opts \\ []),
    to: Humiex.Query

  @doc """
  Makes a search request to the Humio API and synchronously returns only the events

  Takes a Humiex.Client configuration, Query String, Start Time, End Time and options

  ## examples
      iex> client = Humiex.new_client("https://my-humio-host.com", "my_repo", "my_token")
      iex> query_string = "#env=dev #type=log foo"

      iex> relative_start = "1s"
      iex> relative_events = Humiex.query_values(client, query_string, relative_start)

      iex> absolute_start = 1604447249
      iex> absolute_events = Humiex.query_values(client, query_string, absolute_start)
  """
  @spec query_values(
          Humiex.Client.t(),
          binary,
          nil | binary | number,
          nil | binary | number,
          keyword
        ) ::
          [any]
  defdelegate query_values(client, query_string, start_time, end_time \\ nil, opts \\ []),
    to: Humiex.Query

  @doc """
  Makes a live search request to the Humio API and asynchronously returns the event and state

  Takes a Humiex.Client configuration, Query String, Start Time and options

  Each streamed result have the shape: `%{value: event, state: state}`

  ## examples
      iex> client = Humiex.new_client("https://my-humio-host.com", "my_repo", "my_token")
      iex> query_string = "#env=dev #type=log foo"

      iex> relative_start = "1s"
      iex> relative_start_stream = Humiex.stream(client, query_string, relative_start)
      iex> stream |> Enum.take(3)

      iex> absolute_start = 1604447249
      iex> absolute_start_stream = Humiex.stream(client, query_string, absolute_start)
      iex> absolute_start_stream |> Enum.take(3)
  """
  @spec stream(Humiex.Client.t(), String.t(), relative_time(), keyword) :: Enumerable.t()
  defdelegate stream(client, query_string, start_time \\ nil, opts \\ []), to: Humiex.Stream

  @doc """
  Makes a live search request to the Humio API and asynchronously returns the events

  Takes a Humiex.Client configuration, Query String, Start Time and options

  Each streamed result is one humio event.

  The State is sent as a message `{:updated_humio_query_state, state}`
  for each event streamed. The message is sent to the current process by default, a custom
  recipient pid can be passed using the opt `:state_dest`
  ## examples
      iex> client = Humiex.new_client("https://my-humio-host.com", "my_repo", "my_token")
      iex> query_string = "#env=dev #type=log foo"

      iex> start = "1s"
      iex> stream = Humiex.stream_values(client, query_string, start)
      iex> [event] = stream |> Enum.take(1)
      [
        %{...}
      ]
      iex> flush
      ...
      {:updated_humio_query_state, %Humiex.State{...}}
      :ok

      iex> {:ok, pid} = Task.start(fn ->
      ...> receive do
      ...>   {:updated_humio_query_state, state} -> IO.inspect(state)
      ...>   _ -> :ok
      ...> end end)
      iex> stream = Humiex.stream(client, query_string, start, state_dest: pid)
      iex> stream |> Enum.take(1)
      %Humiex.State{...}
      [
        %{...}
      ]
  """
  @spec stream_values(Humiex.Client.t(), String.t(), maybe_time(), keyword) :: Enumerable.t()
  defdelegate stream_values(client, query_string, start_time, opts \\ []), to: Humiex.Stream

  @doc """
  Makes a live search request to the Humio API and asynchronously returns the event and state

  Takes a previous Humiex.State and continues from where it left off based on the `last_timestamp` and `latest_ids`

  Each streamed result have the shape: `%{value: event, state: state}`

  ## examples
      iex> client = Humiex.new_client("https://my-humio-host.com", "my_repo", "my_token")
      iex> query_string = "#env=dev #type=log foo"

      iex> relative_start = "1s"
      iex> [%{state: state}] = Humiex.stream(client, query_string, relative_start) |> Enum.take(1)
      iex> next_events = Humiex.stream(state) |> Enum.take(100)
  """
  @spec stream(Humiex.State.t()) :: Enumerable.t()
  defdelegate stream(state), to: Humiex.Stream

  @doc """
  Makes a live search request to the Humio API and asynchronously returns the events

  Takes a previous Humiex.State and continues from where it left off based on the `last_timestamp` and `latest_ids`

  Each streamed result is one humio event.

  The State is sent as a message `{:updated_humio_query_state, state}`
  for each event streamed.
  The message is sent to the process specified in the State option `:state_dest` (current process by default)

  ## examples
      iex> client = Humiex.new_client("https://my-humio-host.com", "my_repo", "my_token")
      iex> query_string = "#env=dev #type=log foo"

      iex> relative_start = "1s"
      iex> [%{value: _value, state: state}] = Humiex.stream(client, query_string, relative_start) |> Enum.take(1)
      iex> next_events = Humiex.stream_values(state) |> Enum.take(100)
      [
        %{...},
        ...
      ]
      iex> flush
      ...
      {:updated_humio_query_state, %Humiex.State{...}}
      :ok
  """
  @spec stream_values(Humiex.State.t()) :: Enumerable.t()
  defdelegate stream_values(state), to: Humiex.Stream
end
