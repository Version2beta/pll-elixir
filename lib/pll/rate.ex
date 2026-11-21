# complete; do not change
defmodule PLL.Rate do
  @moduledoc "Exact reduced units/second. Use factories; the zero struct is invalid."
  import Kernel, except: [to_string: 1]
  defstruct num: 0, den: 0
  @opaque t :: %__MODULE__{num: non_neg_integer(), den: non_neg_integer()}

  @doc "Reduced num/den, with uint64 input envelopes and README errors."
  @spec units_per_second(term(), term()) :: {:ok, t()} | {:error, PLL.Error.t()}
  defdelegate units_per_second(num, den), to: PLL.RateCore

  @doc "Reduced bits/bits_per_unit; identical validation to units_per_second/2."
  @spec bits_per_second(term(), term()) :: {:ok, t()} | {:error, PLL.Error.t()}
  defdelegate bits_per_second(bits, bits_per_unit), to: PLL.RateCore

  @spec num(t()) :: non_neg_integer()
  def num(%__MODULE__{num: num}), do: num
  def num(_), do: raise(ArgumentError, "expected PLL.Rate")

  @spec den(t()) :: non_neg_integer()
  def den(%__MODULE__{den: den}), do: den
  def den(_), do: raise(ArgumentError, "expected PLL.Rate")

  @doc "Integer/fraction units/s, or invalid rate for the zero sentinel."
  @spec to_string(t()) :: String.t()
  defdelegate to_string(rate), to: PLL.RateCore
end

defimpl String.Chars, for: PLL.Rate do
  def to_string(rate), do: PLL.Rate.to_string(rate)
end
