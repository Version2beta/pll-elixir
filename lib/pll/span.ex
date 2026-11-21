# complete; do not change
defmodule PLL.Span do
  @moduledoc "Read-only-by-contract issued extent with independent immutable timing."
  defstruct first: 0, count: 0, segment: nil

  @opaque t :: %__MODULE__{
            first: non_neg_integer(),
            count: non_neg_integer(),
            segment: PLL.Segment.t() | nil
          }

  @doc "Floor of exact slot time. Noninteger index: ArgumentError; invalid integer: Enum.OutOfBoundsError."
  @spec time(t(), term()) :: non_neg_integer()
  defdelegate time(span, i), to: PLL.SpanCore

  @doc "Fresh lazy Enumerable of {slot, ns}. Stops computing when the consumer stops."
  @spec all(t()) :: Enumerable.t()
  defdelegate all(span), to: PLL.SpanCore
end
