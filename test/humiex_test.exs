defmodule HumiexTest do
  use ExUnit.Case
  alias HumiexTest.{TestHTTPClient, TestResponse}

  test "can take some events from the stream" do
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
    assert last_state.last_timestamp == 1603895394171
    assert last_state.latest_ids == ["zGj7joWFnjgTl1quAiVqOBu5_1401_1481_1603895934"]
  end
end
