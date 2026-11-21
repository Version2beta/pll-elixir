# complete; do not change
defmodule PLL.State do
  @moduledoc "README atom and byte spellings."
  import Kernel, except: [to_string: 1]
  @spec to_string(atom() | byte()) :: String.t()
  def to_string(v) when v in [:acquiring, 0], do: "acquiring"
  def to_string(v) when v in [:locked, 1], do: "locked"
  def to_string(v) when v in [:holdover, 2], do: "holdover"
  def to_string(v) when is_integer(v) and v in 0..255, do: "State(#{v})"
  def to_string(_), do: raise(ArgumentError, "expected State atom or byte")
end
