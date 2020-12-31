defmodule Humiex.Client do
  @moduledoc """
  Humiex Client configuration

  Stores the url, repo and token needed to use the Search API
  """
  alias Humiex.Client.HTTPClient

  defstruct [:url, :repo, :token, :headers, :http_client, :opts]

  @type header() :: {String.t(), String.t()}
  @type token() :: String.t()
  @type t :: %__MODULE__{
          url: String.t(),
          repo: String.t(),
          token: token(),
          headers: [header()],
          http_client: any
        }

  @spec new(String.t(), String.t(), token(), keyword()) :: Humiex.Client.t()
  def new(base_url, repo, token, opts \\ []) do
    headers = [
      {"authorization", "Bearer #{token}"},
      {"Content-Type", "application/json"},
      {"Accept", "application/x-ndjson"}
    ]

    http_client = Keyword.get(opts, :http_client, HTTPClient)

    path = "/api/v1/repositories/#{repo}/query"
    url = base_url <> path

    %__MODULE__{
      url: url,
      repo: repo,
      token: token,
      headers: headers,
      http_client: http_client,
      opts: opts
    }
  end
end
