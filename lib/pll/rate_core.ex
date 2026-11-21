defmodule PLL.RateCore do
  @moduledoc false
  import Kernel, except: [to_string: 1]

  # README envelope U = 2^64 - 1 for unsigned rate terms.
  @max_term 18_446_744_073_709_551_615

  @doc "Implement README Rate factories: uint64 validation, zero rejection, gcd reduction."
  @spec units_per_second(term(), term()) :: {:ok, PLL.Rate.t()} | {:error, PLL.Error.t()}
  def units_per_second(num, den), do: factory(num, den)

  @doc "Same contract as units_per_second/2."
  @spec bits_per_second(term(), term()) :: {:ok, PLL.Rate.t()} | {:error, PLL.Error.t()}
  def bits_per_second(bits, bits_per_unit), do: factory(bits, bits_per_unit)

  @doc "README exact spelling, including invalid zero Rate; wrong kind raises ArgumentError."
  @spec to_string(PLL.Rate.t()) :: String.t()
  def to_string(%PLL.Rate{num: num, den: den}) when num > 0 and den > 0 do
    if den == 1 do
      Integer.to_string(num) <> " units/s"
    else
      Integer.to_string(num) <> "/" <> Integer.to_string(den) <> " units/s"
    end
  end

  def to_string(%PLL.Rate{}), do: "invalid rate"
  def to_string(_), do: raise(ArgumentError, "expected PLL.Rate")

  # Scalars are checked left-to-right (type, then envelope) before any semantic
  # check; the first failing scalar determines the error.
  defp factory(num, den) do
    with {:ok, n} <- scalar(num),
         {:ok, d} <- scalar(den) do
      reduce(n, d)
    end
  end

  defp scalar(v) when is_integer(v) and v >= 0 and v <= @max_term, do: {:ok, v}
  defp scalar(v) when is_integer(v), do: {:error, %PLL.Error{code: :overflow}}
  defp scalar(_), do: {:error, %PLL.Error{code: :invalid_argument}}

  defp reduce(0, _den), do: {:error, %PLL.Error{code: :invalid_rate}}
  defp reduce(_num, 0), do: {:error, %PLL.Error{code: :invalid_rate}}

  defp reduce(num, den) do
    g = Integer.gcd(num, den)
    {:ok, %PLL.Rate{num: div(num, g), den: div(den, g)}}
  end
end
