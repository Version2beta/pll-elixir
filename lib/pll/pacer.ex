# complete; do not change
defmodule PLL.Pacer do
  @moduledoc "Immutable exact cursor. Times are caller-supplied integer nanoseconds."
  defstruct rate: %PLL.Rate{}, cursor: 0, segment: %PLL.Segment{}

  @opaque t :: %__MODULE__{
            rate: PLL.Rate.t(),
            cursor: non_neg_integer(),
            segment: PLL.Segment.t()
          }
  @type result :: {:ok, t(), PLL.Span.t()} | {:error, PLL.Error.t()}

  @doc "Starts slot zero at zero ns and zero trim; invalid Rate is a tagged error."
  @spec new(PLL.Rate.t()) :: {:ok, t()} | {:error, PLL.Error.t()}
  defdelegate new(rate), to: PLL.PacerCore

  @doc "Issue oldest exact-due slots, capped. Earlier now is allowed; never issue slot U."
  @spec due(t(), term(), term()) :: result()
  defdelegate due(pacer, now_ns, max_count), to: PLL.PacerCore

  @doc "Issue n slots regardless of now; check last floor and first+count <= U."
  @spec claim(t(), term()) :: result()
  defdelegate claim(pacer, n), to: PLL.PacerCore

  @doc "Skip all due except newest keep; cursor U overflows only if itself due."
  @spec skip(t(), term(), term()) :: {:ok, t(), non_neg_integer()} | {:error, PLL.Error.t()}
  defdelegate skip(pacer, now_ns, keep), to: PLL.PacerCore

  @doc "Cursor and ceiling of its exact time; cursor U or ceiling > Imax overflows."
  @spec next_due(t()) :: {:ok, {non_neg_integer(), non_neg_integer()}} | {:error, PLL.Error.t()}
  defdelegate next_due(pacer), to: PLL.PacerCore

  @doc "Re-anchor at old cursor floor, unless same trim (true no-op). Old spans keep timing."
  @spec set_trim(t(), term()) :: {:ok, t()} | {:error, PLL.Error.t()}
  defdelegate set_trim(pacer, ppt), to: PLL.PacerCore

  @spec trim(t()) :: integer()
  defdelegate trim(pacer), to: PLL.PacerCore
end
