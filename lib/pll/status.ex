# complete; do not change
defmodule PLL.Status do
  @moduledoc "README atom and byte spellings."
  import Kernel, except: [to_string: 1]
  @spec to_string(atom() | byte()) :: String.t()
  def to_string(v) when v in [:anchored, 1], do: "anchored"
  def to_string(v) when v in [:accepted, 2], do: "accepted"
  def to_string(v) when v in [:pending, 3], do: "pending"
  def to_string(v) when v in [:rejected, 4], do: "rejected"
  def to_string(v) when v in [:stepped, 5], do: "stepped"
  def to_string(v) when is_integer(v) and v in 0..255, do: "Status(#{v})"
  def to_string(_), do: raise(ArgumentError, "expected Status atom or byte")
end
