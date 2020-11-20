defmodule HumiexTest do
  use ExUnit.Case
  alias Humiex.State
  alias HumiexTest.{TestHTTPClient, TestResponse}
  Logger.configure(level: :warning)

  test "Can generate a Humiex Client" do
    client = Humiex.new_client("mock", "test", "my_token")
    assert %Humiex.Client{url: "mock/api/v1/repositories/test/query"} = client
  end

  test "can take some events from the stream built from state" do
    test_state =
      %TestResponse{
        status: 200,
        headers: [
          {"Content-Type", "application/x-ndjson"}
        ],
        chunks: [
          "{\"#repo\":\"test\",\"@id\":\"zGj7joWFnjgTl1quAiVqOBu5_1399_1481_1603895394\",\"@rawstring\":\"{\\\"message\\\":\\\"foo\\\"}\",\"@timestamp\":1603895394170,\"@timezone\":\"UTC\",\"message\":\"foo\"}\n{\"#repo\":\"test\",\"@id\":\"zGj7joWFnjgTl1quAiVqOBu5_1400_1453_1632895394\",\"@rawstring\":\"{\\\"message\\\":\\\"bar\\\"}\",\"@timestamp\":1603895394170,\"@timezone\":\"UTC\",\"message\":\"bar\"}\n{\"#repo\":\"test\",\"@id\":\"zGj7joW",
          "FnjgTl1quAiVqOBu5_1401_1481_1603895934\",\"@rawstring\":\"{\\\"message\\\":\\\"baz\\\"}\",\"@timestamp\":1603895394171,\"@timezone\":\"UTC\",\"message\":\"baz\"}\n"
        ]
      }
      |> TestHTTPClient.setup()

    events =
      test_state
      |> Humiex.stream()
      |> Enum.take(2)

    %{value: _last_value, state: last_state} = events |> List.last()

    expected_ids =
      [
        "zGj7joWFnjgTl1quAiVqOBu5_1400_1453_1632895394",
        "zGj7joWFnjgTl1quAiVqOBu5_1399_1481_1603895394"
      ]
      |> MapSet.new()

    assert length(events) == 2
    assert last_state.last_timestamp == 1_603_895_394_170
    assert last_state.latest_ids |> MapSet.new() |> MapSet.equal?(expected_ids)
  end

  test "can take some events from the stream built from client" do
    %State{client: client} =
      %TestResponse{
        status: 200,
        headers: [
          {"Content-Type", "application/x-ndjson"}
        ],
        chunks: [
          "{\"#repo\":\"test\",\"@id\":\"zGj7joWFnjgTl1quAiVqOBu5_1399_1481_1603895394\",\"@rawstring\":\"{\\\"message\\\":\\\"foo\\\"}\",\"@timestamp\":1603895394170,\"@timezone\":\"UTC\",\"message\":\"foo\"}\n{\"#repo\":\"test\",\"@id\":\"zGj7joWFnjgTl1quAiVqOBu5_1400_1453_1632895394\",\"@rawstring\":\"{\\\"message\\\":\\\"bar\\\"}\",\"@timestamp\":1603895394170,\"@timezone\":\"UTC\",\"message\":\"bar\"}\n{\"#repo\":\"test\",\"@id\":\"zGj7joW",
          "FnjgTl1quAiVqOBu5_1401_1481_1603895934\",\"@rawstring\":\"{\\\"message\\\":\\\"baz\\\"}\",\"@timestamp\":1603895394171,\"@timezone\":\"UTC\",\"message\":\"baz\"}\n"
        ]
      }
      |> TestHTTPClient.setup()

    events =
      client
      |> Humiex.stream("some query", "1s")
      |> Enum.take(2)

    %{value: _last_value, state: last_state} = events |> List.last()

    expected_ids =
      [
        "zGj7joWFnjgTl1quAiVqOBu5_1400_1453_1632895394",
        "zGj7joWFnjgTl1quAiVqOBu5_1399_1481_1603895394"
      ]
      |> MapSet.new()

    assert length(events) == 2
    assert last_state.last_timestamp == 1_603_895_394_170
    assert last_state.latest_ids |> MapSet.new() |> MapSet.equal?(expected_ids)
  end

  test "can take some events from the stream built from client w/o start_time" do
    %State{client: client} =
      %TestResponse{
        status: 200,
        headers: [
          {"Content-Type", "application/x-ndjson"}
        ],
        chunks: [
          "{\"#repo\":\"test\",\"@id\":\"zGj7joWFnjgTl1quAiVqOBu5_1399_1481_1603895394\",\"@rawstring\":\"{\\\"message\\\":\\\"foo\\\"}\",\"@timestamp\":1603895394170,\"@timezone\":\"UTC\",\"message\":\"foo\"}\n{\"#repo\":\"test\",\"@id\":\"zGj7joWFnjgTl1quAiVqOBu5_1400_1453_1632895394\",\"@rawstring\":\"{\\\"message\\\":\\\"bar\\\"}\",\"@timestamp\":1603895394170,\"@timezone\":\"UTC\",\"message\":\"bar\"}\n{\"#repo\":\"test\",\"@id\":\"zGj7joW",
          "FnjgTl1quAiVqOBu5_1401_1481_1603895934\",\"@rawstring\":\"{\\\"message\\\":\\\"baz\\\"}\",\"@timestamp\":1603895394171,\"@timezone\":\"UTC\",\"message\":\"baz\"}\n"
        ]
      }
      |> TestHTTPClient.setup()

    events =
      client
      |> Humiex.stream("some query")
      |> Enum.take(2)

    %{value: _last_value, state: last_state} = events |> List.last()

    expected_ids =
      [
        "zGj7joWFnjgTl1quAiVqOBu5_1400_1453_1632895394",
        "zGj7joWFnjgTl1quAiVqOBu5_1399_1481_1603895394"
      ]
      |> MapSet.new()

    assert length(events) == 2
    assert last_state.last_timestamp == 1_603_895_394_170
    assert last_state.latest_ids |> MapSet.new() |> MapSet.equal?(expected_ids)
  end

  test "can take some event values from the stream built from client" do
    %State{client: client} =
      %TestResponse{
        status: 200,
        headers: [
          {"Content-Type", "application/x-ndjson"}
        ],
        chunks: [
          "{\"#repo\":\"test\",\"@id\":\"zGj7joWFnjgTl1quAiVqOBu5_1399_1481_1603895394\",\"@rawstring\":\"{\\\"message\\\":\\\"foo\\\"}\",\"@timestamp\":1603895394170,\"@timezone\":\"UTC\",\"message\":\"foo\"}\n{\"#repo\":\"test\",\"@id\":\"zGj7joWFnjgTl1quAiVqOBu5_1400_1453_1632895394\",\"@rawstring\":\"{\\\"message\\\":\\\"bar\\\"}\",\"@timestamp\":1603895394170,\"@timezone\":\"UTC\",\"message\":\"bar\"}\n{\"#repo\":\"test\",\"@id\":\"zGj7joW",
          "FnjgTl1quAiVqOBu5_1401_1481_1603895934\",\"@rawstring\":\"{\\\"message\\\":\\\"baz\\\"}\",\"@timestamp\":1603895394171,\"@timezone\":\"UTC\",\"message\":\"baz\"}\n"
        ]
      }
      |> TestHTTPClient.setup()

    events =
      client
      |> Humiex.stream_values("some query", "1s")
      |> Enum.take(2)

    assert_receive {:updated_humio_query_state, %State{}}
    assert length(events) == 2
  end

  test "can query all events" do
    %State{client: client} =
      %TestResponse{
        status: 200,
        headers: [
          {"Content-Type", "application/x-ndjson"}
        ],
        chunks: [
          "{\"#repo\":\"test\",\"@id\":\"zGj7joWFnjgTl1quAiVqOBu5_1399_1481_1603895394\",\"@rawstring\":\"{\\\"message\\\":\\\"foo\\\"}\",\"@timestamp\":1603895394170,\"@timezone\":\"UTC\",\"message\":\"foo\"}\n{\"#repo\":\"test\",\"@id\":\"zGj7joWFnjgTl1quAiVqOBu5_1400_1453_1632895394\",\"@rawstring\":\"{\\\"message\\\":\\\"bar\\\"}\",\"@timestamp\":1603895394170,\"@timezone\":\"UTC\",\"message\":\"bar\"}\n{\"#repo\":\"test\",\"@id\":\"zGj7joW",
          "FnjgTl1quAiVqOBu5_1401_1481_1603895934\",\"@rawstring\":\"{\\\"message\\\":\\\"baz\\\"}\",\"@timestamp\":1603895394171,\"@timezone\":\"UTC\",\"message\":\"baz\"}\n"
        ]
      }
      |> TestHTTPClient.setup()

    expected_ids =
      [
        "zGj7joWFnjgTl1quAiVqOBu5_1401_1481_1603895934"
      ]
      |> MapSet.new()

    res = Humiex.query(client, "some query", "1s")

    assert {:ok, events, state} = res

    assert length(events) == 3

    assert %{
             "#repo" => "test",
             "@id" => "zGj7joWFnjgTl1quAiVqOBu5_1399_1481_1603895394",
             "@rawstring" => "{\"message\":\"foo\"}",
             "@timestamp" => 1_603_895_394_170,
             "@timezone" => "UTC",
             "message" => "foo"
           } = events |> List.last()

    assert state.latest_ids |> MapSet.new() |> MapSet.equal?(expected_ids)
  end

  test "gets correct last_timestamp even if events are not in the correct order" do
    %State{client: client} =
      %TestResponse{
        status: 200,
        headers: [
          {"Content-Type", "application/x-ndjson"}
        ],
        chunks: [
          "{\"#repo\":\"test\",\"@id\":\"zGj7joWFnjgTl1quAiVqOBu5_1399_1481_1603895394\",\"@rawstring\":\"{\\\"message\\\":\\\"foo\\\"}\",\"@timestamp\":1703895394170,\"@timezone\":\"UTC\",\"message\":\"foo\"}\n{\"#repo\":\"test\",\"@id\":\"zGj7joWFnjgTl1quAiVqOBu5_1400_1453_1632895394\",\"@rawstring\":\"{\\\"message\\\":\\\"bar\\\"}\",\"@timestamp\":1603895394170,\"@timezone\":\"UTC\",\"message\":\"bar\"}\n{\"#repo\":\"test\",\"@id\":\"zGj7joW",
          "FnjgTl1quAiVqOBu5_1401_1481_1603895934\",\"@rawstring\":\"{\\\"message\\\":\\\"baz\\\"}\",\"@timestamp\":1603895394171,\"@timezone\":\"UTC\",\"message\":\"baz\"}\n"
        ]
      }
      |> TestHTTPClient.setup()

    expected_ids =
      [
        "zGj7joWFnjgTl1quAiVqOBu5_1399_1481_1603895394"
      ]
      |> MapSet.new()

    res = Humiex.query(client, "some query", "1s")

    assert {:ok, events, state} = res
    assert state.last_timestamp == 1_703_895_394_170
    assert state.latest_ids |> MapSet.new() |> MapSet.equal?(expected_ids)
  end

  test "can query all event values" do
    %State{client: client} =
      %TestResponse{
        status: 200,
        headers: [
          {"Content-Type", "application/x-ndjson"}
        ],
        chunks: [
          "{\"#repo\":\"test\",\"@id\":\"zGj7joWFnjgTl1quAiVqOBu5_1399_1481_1603895394\",\"@rawstring\":\"{\\\"message\\\":\\\"foo\\\"}\",\"@timestamp\":1603895394170,\"@timezone\":\"UTC\",\"message\":\"foo\"}\n{\"#repo\":\"test\",\"@id\":\"zGj7joWFnjgTl1quAiVqOBu5_1400_1453_1632895394\",\"@rawstring\":\"{\\\"message\\\":\\\"bar\\\"}\",\"@timestamp\":1603895394170,\"@timezone\":\"UTC\",\"message\":\"bar\"}\n{\"#repo\":\"test\",\"@id\":\"zGj7joW",
          "FnjgTl1quAiVqOBu5_1401_1481_1603895934\",\"@rawstring\":\"{\\\"message\\\":\\\"baz\\\"}\",\"@timestamp\":1603895394171,\"@timezone\":\"UTC\",\"message\":\"baz\"}\n"
        ]
      }
      |> TestHTTPClient.setup()

    events = Humiex.query_values(client, "some query", "1s")

    assert length(events) == 3

    assert %{
             "#repo" => "test",
             "@id" => "zGj7joWFnjgTl1quAiVqOBu5_1401_1481_1603895934",
             "@rawstring" => "{\"message\":\"baz\"}",
             "@timestamp" => 1_603_895_394_171,
             "@timezone" => "UTC",
             "message" => "baz"
           } = events |> Enum.sort_by(fn event -> event["@timestamp"] end, :asc) |> List.last()
  end

  test "handles error in Humiex.query" do
    error_msg =
      "Could not parse expression:\n```\nExpected an expression.\n 1: #env=dev #type=metricservice=mystiquemeasurement=vm.memory\n                                ^\n```"

    %State{client: client} =
      %TestResponse{
        status: 400,
        headers: [
          {"Content-Type", "application/x-ndjson"}
        ],
        chunks: [
          error_msg
        ]
      }
      |> TestHTTPClient.setup()

    res =
      client
      |> Humiex.query("some query", "1s")

    assert {:error, %{code: 400, message: ^error_msg}, %State{}} = res
  end

  test "handles error in Humiex.query_values" do
    error_msg =
      "Could not parse expression:\n```\nExpected an expression.\n 1: #env=dev #type=metricservice=mystiquemeasurement=vm.memory\n                                ^\n```"

    %State{client: client} =
      %TestResponse{
        status: 400,
        headers: [
          {"Content-Type", "application/x-ndjson"}
        ],
        chunks: [
          error_msg
        ]
      }
      |> TestHTTPClient.setup()

    res =
      client
      |> Humiex.query_values("some query", "1s")

    assert [{:error, %{code: 400, message: ^error_msg}, %State{}}] = res
  end

  test "handles bad domain" do
    test_response = %TestResponse{
      status: 200,
      headers: [
        {"Content-Type", "application/x-ndjson"}
      ],
      chunks: [
        ""
      ]
    }

    assert_raise(TestHTTPClient.Error, fn ->
      test_response
      |> TestHTTPClient.setup(url: "bad_domain")
      |> Humiex.stream()
      |> Enum.take(10)
    end)
  end

  test "handles invalid token" do
    test_response = %TestResponse{
      status: 401,
      headers: [
        {"Content-Type", "application/x-ndjson"}
      ],
      chunks: [
        "The supplied authentication is invalid"
      ]
    }

    [event] =
      events =
      test_response
      |> TestHTTPClient.setup()
      |> Humiex.stream()
      |> Enum.take(10)

    assert length(events) == 1

    assert {:error, %{code: 401, message: "The supplied authentication is invalid"}, %State{}} =
             event

    [event] =
      events =
      test_response
      |> TestHTTPClient.setup()
      |> Humiex.stream_values()
      |> Enum.take(10)

    assert length(events) == 1

    assert {:error, %{code: 401, message: "The supplied authentication is invalid"}, %State{}} =
             event
  end

  test "handles invalid query" do
    error_msg =
      "Could not parse expression:\n```\nExpected an expression.\n 1: #env=dev #type=metricservice=mystiquemeasurement=vm.memory\n                                ^\n```"

    test_response = %TestResponse{
      status: 400,
      headers: [
        {"Content-Type", "application/x-ndjson"}
      ],
      chunks: [
        error_msg
      ]
    }

    [event] =
      events =
      test_response
      |> TestHTTPClient.setup()
      |> Humiex.stream()
      |> Enum.take(10)

    assert length(events) == 1

    assert {:error, %{code: 400, message: ^error_msg}, %State{}} = event

    [event] =
      events =
      test_response
      |> TestHTTPClient.setup()
      |> Humiex.stream_values()
      |> Enum.take(10)

    assert length(events) == 1

    assert {:error, %{code: 400, message: ^error_msg}, %State{}} = event
  end

  test "handles redirection error" do
    error_msg =
      "<html>\r\n<head><title>301 Moved Permanently</title></head>\r\n<body>\r\n<center><h1>301 Moved Permanently</h1></center>\r\n</body>\r\n</html>\r\n"

    test_response = %TestResponse{
      status: 301,
      headers: [
        {"Content-Type", "application/x-ndjson"}
      ],
      chunks: [
        error_msg
      ]
    }

    [event] =
      events =
      test_response
      |> TestHTTPClient.setup()
      |> Humiex.stream()
      |> Enum.take(10)

    assert length(events) == 1

    assert {:error, %{code: 301, message: ^error_msg}, %State{}} = event

    [event] =
      events =
      test_response
      |> TestHTTPClient.setup()
      |> Humiex.stream_values()
      |> Enum.take(10)

    assert length(events) == 1

    assert {:error, %{code: 301, message: ^error_msg}, %State{}} = event
  end

  test "can reconstruct line splitted in two chunks" do
    test_state =
      %TestResponse{
        status: 200,
        headers: [
          {"Content-Type", "application/x-ndjson"}
        ],
        chunks: [
          "{\"#repo\":\"test\",\"@id\":\"zGj7joWFnjgTl1quAiVqOBu5_1399_1481_1603895394\",\"@rawstring\":\"{\\\"message\\\":\\\"foo\\\"}\",\"@timestamp\":1603895394170,\"@timezone\":\"UTC\",\"message\":\"foo\"}\n{\"#repo\":\"test\",\"@id\":\"zGj7joWFnjgTl1quAiVqOBu5_1400_1453_1632895394\",\"@rawstring\":\"{\\\"message\\\":\\\"bar\\\"}\",\"@timestamp\":1603895394170,\"@timezone\":\"UTC\",\"message\":\"bar\"}\n{\"#repo\":\"test\",\"@id\":\"zGj7joW",
          "FnjgTl1quAiVqOBu5_1401_1481_1603895934\",\"@rawstring\":\"{\\\"message\\\":\\\"baz\\\"}\",\"@timestamp\":1603895394171,\"@timezone\":\"UTC\",\"message\":\"baz\"}\n"
        ]
      }
      |> TestHTTPClient.setup()

    events =
      test_state
      |> Humiex.stream()
      |> Enum.take(3)

    %{value: last_value, state: last_state} = events |> List.last()

    assert length(events) == 3
    assert last_value["@id"] == "zGj7joWFnjgTl1quAiVqOBu5_1401_1481_1603895934"
    assert last_state.last_timestamp == 1_603_895_394_171
    assert last_state.latest_ids == ["zGj7joWFnjgTl1quAiVqOBu5_1401_1481_1603895934"]
  end
end
