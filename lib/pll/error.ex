# complete; do not change
defmodule PLL.Error do
  @moduledoc "Tagged error value; match code/field, not message text."
  defstruct code: nil, field: nil, reason: nil

  @type t :: %__MODULE__{code: atom(), field: atom() | nil, reason: String.t() | nil}

  @spec message(t()) :: String.t()
  def message(%__MODULE__{code: :invalid_rate}), do: "pll: invalid rate"
  def message(%__MODULE__{code: :invalid_argument}), do: "pll: invalid argument"
  def message(%__MODULE__{code: :overflow}), do: "pll: overflow"
  def message(%__MODULE__{code: :order}), do: "pll: reading out of order"
  def message(%__MODULE__{code: :not_anchored}), do: "pll: follower has no reading yet"

  def message(%__MODULE__{code: :config, field: field, reason: reason}),
    do: "pll: FollowerConfig.#{field} #{reason}"

  def message(%__MODULE__{code: :unsupported}), do: "pll: unsupported in Stage 2"
end
