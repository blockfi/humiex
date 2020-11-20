defmodule HumiexTest.TestHTTPClient do
  @moduledoc """
  Implements a HTTP Clients for tests that conform to the behaviour Humiex.Runner.Streamer uses

  * setup/1 allows to specify the response sent.
  """
  @behaviour Humiex.HTTPAsyncBehaviour
  require Logger
  alias Humiex.{Client, State}
  alias HumiexTest.TestResponse

  defmodule Error do
    defexception [:message]
  end

  def setup(%TestResponse{} = response, opts \\ []) do
    response_list = [
      status: response.status,
      headers: response.headers,
      chunks: response.chunks,
      response_end: response.response_end
    ]

    {:ok, pid} = Agent.start(fn -> response_list end)

    url = Keyword.get(opts, :url, "mock")

    %State{
      client: Humiex.new_client(url, "test", "my_token", http_client: __MODULE__, resp: pid),
      resp: pid
    }
  end

  def get_next(pid) do
    msg =
      Agent.get_and_update(pid, fn
        [{:status, _code} = msg | rest] ->
          {msg, rest}

        [{:headers, _headers} = msg | rest] ->
          {msg, rest}

        [{:chunks, [chunk | []]} | rest] ->
          {{:chunk, chunk}, rest}

        [{:chunks, [chunk | rest_chunks]} | rest] ->
          {{:chunk, chunk}, [{:chunks, rest_chunks} | rest]}

        [{:response_end, :response_end}] ->
          {:response_end, []}
      end)

    send(self(), msg)
  end

  @impl true
  def start(%State{client: %Client{url: "bad_domain/api/v1/repositories/test/query"}}) do
    raise(HumiexTest.TestHTTPClient.Error, "nxdomain")
  end

  @impl true
  def start(%State{resp: nil, client: %Client{opts: opts}} = state) do
    resp = Keyword.get(opts, :resp)

    fn ->
      get_next(resp)
      %State{state | resp: resp}
    end
  end

  def start(%State{resp: resp} = state) do
    fn ->
      get_next(resp)
      state
    end
  end

  @impl true
  def next(%State{resp: resp} = state) do
    receive do
      {:status, code} when code < 299 ->
        Logger.debug("STATUS: #{code}")
        get_next(resp)
        {[], %State{state | status: :ok, response_code: code}}

      {:status, code} ->
        Logger.debug("STATUS: #{code}")
        get_next(resp)
        {[], %State{state | status: :error, response_code: code}}

      {:headers, headers} ->
        Logger.debug("RESPONSE HEADERS: #{inspect(headers)}")
        get_next(resp)
        {[], state}

      {:chunk, chunk} ->
        get_next(resp)
        new_state = %State{state | chunk: chunk}
        {[new_state], new_state}

      :response_end ->
        {:halt, state}
    end
  end

  @impl true
  def stop(%State{resp: resp} = state) do
    Agent.stop(resp)
    {:ok, state}
  end
end
