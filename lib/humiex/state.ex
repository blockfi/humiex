defmodule Humiex.State do
  @moduledoc """
  Stores a Humiex Query/Stream search state

  Allows Humiex.stream/1 and Humiex.stream_values/1 to resume a Search from a previous one
  """

  alias Humiex.Client
  alias Humiex.Runner.HTTPClient

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
            http_client: HTTPClient

  @type relative_time() :: String.t()
  @type absolute_time() :: number()
  @type time() :: relative_time() | absolute_time()
  @type maybe_time() :: time() | nil
  @type event_id() :: String.t()
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
          opts: keyword
        }
end
