defmodule Humiex.Runner do
  @moduledoc false
  alias Humiex.Runner.Streamer

  defdelegate start(state), to: Streamer
end
