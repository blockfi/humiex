defmodule Humiex.State do
  @moduledoc """
  Stores a Humiex Query/Stream search state

  Allows Humiex.stream/1 and Humiex.stream_values/1 to resume a Search from a previous one
  """

  alias Humiex.Client

  require Logger
  @enforce_keys [:client]
  defstruct client: nil,
            query_string: "",
            start_time: nil,
            end_time: nil,
            opts: [],
            resp: nil,
            chunk: nil,
            latest_ids: [],
            last_timestamp: 0,
            event_count: 0,
            response_code: nil,
            status: nil

  @type relative_time() :: String.t()
  @type absolute_time() :: number()
  @type time() :: relative_time() | absolute_time()
  @type maybe_time() :: time() | nil
  @type event_id() :: String.t()

  @typedoc """
  A Humiex State struct
  stores the client and query configuration alongside
  execution metadata such as the latest seen event timestamp and event ids

  - `:client` Humiex Client configuration
  - `:query_string` Humio search API queryString
  - `:start_time` Humio search API start time specification
  - `:end_time` Humio search API end time specification
  - `:opts` Keyword of additional options such as
    - `:live?` uses a live query if set to `true`
    - `:state_dest` allows to send the Humiex.State as a message to a process when using `stream_values/4`
  - `:resp` Holds a reference to the Client that implements HTTPAsyncBehaviour and it's used to execute the requests
  - `:last_timestamp` Last seen timestamp
  - `:latest_ids` List of the seen event ids for the last timestamp
  - `:event_count` Number of events returned so far
  - `:chunk` Internal buffer used to hold the raw api responses before decoding the events
  """
  @type t :: %__MODULE__{
          client: Client.t(),
          query_string: String.t(),
          start_time: maybe_time(),
          end_time: maybe_time(),
          resp: any,
          last_timestamp: number(),
          latest_ids: [event_id()],
          event_count: number(),
          chunk: binary() | nil,
          opts: keyword,
          response_code: number() | nil,
          status: :ok | :error | nil,
        }
end
