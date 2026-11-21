# complete; do not change
defmodule PLL.Observation do
  @moduledoc "Reading result; error_ns is phase error, not a tagged failure."
  defstruct status: :anchored, error_ns: 0
  @type t :: %__MODULE__{status: atom(), error_ns: integer()}
end
