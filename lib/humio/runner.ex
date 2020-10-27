defmodule Humio.Runner do
  @moduledoc false
  alias Humio.Runner.Streamer

  defdelegate start(state), to: Streamer
end
