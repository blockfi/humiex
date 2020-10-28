defmodule HumiexTest.TestResponse do
  @moduledoc """
  Defines the struct used to configure the desired response sent by HumiexTest.TestHTTPClient
  """
  @type status :: number
  @type header :: {any, any}
  @type chunk :: String.t()
  @type response_end :: :response_end

  defstruct status: 200, headers: [], chunks: [], response_end: :response_end

  @type t :: %__MODULE__{
    status: status,
    headers: [header],
    chunks: [chunk],
    response_end: :response_end
  }
end
