defmodule PLL.PacerCore do
  @moduledoc false

  @doc "Initialize a valid reduced Rate at slot/time/trim zero; wrong kind raises ArgumentError."
  @spec new(PLL.Rate.t()) :: {:ok, PLL.Pacer.t()} | {:error, PLL.Error.t()}
  def new(_rate), do: {:error, %PLL.Error{code: :invalid_rate}}

  @doc "Exact due comparison, cap and immutable transition; README validation and U rules."
  @spec due(PLL.Pacer.t(), term(), term()) :: PLL.Pacer.result()
  def due(_pacer, _now_ns, _max_count), do: {:error, %PLL.Error{code: :invalid_argument}}

  @doc "Claim positive uint64 n, checking last floor and cursor envelope, without enumeration."
  @spec claim(PLL.Pacer.t(), term()) :: PLL.Pacer.result()
  def claim(_pacer, _n), do: {:error, %PLL.Error{code: :invalid_argument}}

  @doc "Skip due slots except newest keep, with exact due comparison and immutable transition."
  @spec skip(PLL.Pacer.t(), term(), term()) ::
          {:ok, PLL.Pacer.t(), non_neg_integer()} | {:error, PLL.Error.t()}
  def skip(_pacer, _now_ns, _keep), do: {:error, %PLL.Error{code: :invalid_argument}}

  @doc "Return cursor and exact ceiling, or overflow; never enumerate slots."
  @spec next_due(PLL.Pacer.t()) ::
          {:ok, {non_neg_integer(), non_neg_integer()}} | {:error, PLL.Error.t()}
  def next_due(_pacer), do: {:error, %PLL.Error{code: :overflow}}

  @doc "Validate signed trim, same-trim no-op, otherwise floor re-anchor preserving issued spans."
  @spec set_trim(PLL.Pacer.t(), term()) :: {:ok, PLL.Pacer.t()} | {:error, PLL.Error.t()}
  def set_trim(_pacer, _ppt), do: {:error, %PLL.Error{code: :invalid_argument}}

  @doc "Current integer ppt; wrong state kind raises ArgumentError."
  @spec trim(PLL.Pacer.t()) :: integer()
  def trim(_pacer), do: 0
end
