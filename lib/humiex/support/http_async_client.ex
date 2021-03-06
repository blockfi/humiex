defmodule Humiex.Support.HTTPAsyncClient do
  @moduledoc """
  Async HTTP Client behaviour expected to be used with Stream.Resource/3
  """
  alias Humiex.State

  @callback start(State.t()) :: (() -> State.t())
  @callback next(State.t()) :: {[any], State.t()} | {:halt, State.t()}
  @callback stop(State.t()) :: {:ok, any} | {:error, any}
end
