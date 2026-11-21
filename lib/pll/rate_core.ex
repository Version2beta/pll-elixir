defmodule PLL.RateCore do
  @moduledoc false
  import Kernel, except: [to_string: 1]

  @doc "Implement README Rate factories: uint64 validation, zero rejection, gcd reduction."
  @spec units_per_second(term(), term()) :: {:ok, PLL.Rate.t()} | {:error, PLL.Error.t()}
  def units_per_second(_num, _den), do: {:error, %PLL.Error{code: :invalid_rate}}

  @doc "Same contract as units_per_second/2."
  @spec bits_per_second(term(), term()) :: {:ok, PLL.Rate.t()} | {:error, PLL.Error.t()}
  def bits_per_second(_bits, _bits_per_unit), do: {:error, %PLL.Error{code: :invalid_rate}}

  @doc "README exact spelling, including invalid zero Rate; wrong kind raises ArgumentError."
  @spec to_string(PLL.Rate.t()) :: String.t()
  def to_string(_rate), do: "invalid rate"
end
