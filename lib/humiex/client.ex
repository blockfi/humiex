defmodule Humiex.Client do
  @moduledoc """
  Humiex Client configuration

  Stores the url, repo and token needed to use the Search API
  """
  defstruct [:url, :repo, :token, :headers]

  @type header() :: {String.t(), String.t()}
  @type token() :: String.t()
  @type t :: %__MODULE__{
          url: String.t(),
          repo: String.t(),
          token: token(),
          headers: [header()]
        }

  @spec new(String.t(), String.t(), token()) :: Humiex.Client.t()
  def new(base_url, repo, token) do
    headers = [
      {"authorization", "Bearer #{token}"},
      {"Content-Type", "application/json"},
      {"Accept", "application/x-ndjson"}
    ]

    path = "/api/v1/repositories/#{repo}/query"
    url = base_url <> path
    %__MODULE__{url: url, repo: repo, token: token, headers: headers}
  end
end
