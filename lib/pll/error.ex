# complete; do not change
defmodule PLL.Error do
  @moduledoc "Tagged error value; match code/field, not message text."
  defstruct code: nil, field: nil, reason: nil

  @type t :: %__MODULE__{code: atom(), field: atom() | nil, reason: String.t() | nil}

  @spec message(t()) :: String.t()
  def message(%__MODULE__{code: :invalid_rate}), do: "pll: invalid rate"
  def message(%__MODULE__{code: :invalid_argument}), do: "pll: invalid argument"
  def message(%__MODULE__{code: :overflow}), do: "pll: overflow"
end
