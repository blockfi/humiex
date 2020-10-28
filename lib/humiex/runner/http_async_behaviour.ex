defmodule Humiex.HTTPAsyncBehaviour do
  alias Humiex

  @callback start(State.t()) :: (() -> State.t())
  @callback next(State.t()) :: {[any], State.t()} | {:halt, State.t()}
  @callback stop(State.t()) :: {:ok, any} | {:error, any}
end
