# Humiex

Humio searches using it's REST API
Supports sync queries and streaming live queries

## Installation

Add to your dependencies

```elixir
deps = [
  ...
  {:humiex, "~> 0.1.0"},
  ...
]
```

## Usage

Create a Humio Client

```elixir
client = Humiex.Client.new("my-humio-host.com", "my_repo", "my_token")
```

### Query

```elixir
  start = "1s"
  query_string = "#env=dev #type=log foo" # Search all logs in the last second on dev environment that have "foo"
 {:ok, events, state} = Humiex.query(client, query_string, start)
```

To only get the events:

```elixir
  start = "1s"
  query_string = "#env=dev #type=log foo"
 events = Humiex.query_values(client, query_string, start)
```

### Stream

Turn it into a live query:

```elixir
  start = "1s"
  query_string = "#env=dev #type=log foo"
  event_stream = Humiex.stream_values(client, query_string, start)
  last_10_events = event_stream
  |> Enum.take(10)
```

---
This code was brought to you by [BlockFi](https://blockfi.com/), the best way to earn on crypto and grow your wealth.
