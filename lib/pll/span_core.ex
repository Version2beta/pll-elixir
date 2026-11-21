defmodule PLL.SpanCore do
  @moduledoc false

  @doc "Floor segment time at relative index; enforce README index exception contract."
  @spec time(PLL.Span.t(), term()) :: non_neg_integer()
  def time(%PLL.Span{first: first, count: count, segment: segment}, i) when is_integer(i) do
    if i >= 0 and i < count do
      PLL.SegmentCore.floor_time(segment, first + i)
    else
      raise Enum.OutOfBoundsError
    end
  end

  def time(%PLL.Span{}, _i), do: raise(ArgumentError, "span index must be an integer")
  def time(_span, _i), do: raise(ArgumentError, "expected PLL.Span")

  @doc "Fresh lazy enumeration; empty zero Span is valid and early halt avoids all later times."
  @spec all(PLL.Span.t()) :: Enumerable.t()
  def all(%PLL.Span{first: first, count: count, segment: segment}) do
    Stream.map(Range.new(first, first + count - 1, 1), fn slot ->
      {slot, PLL.SegmentCore.floor_time(segment, slot)}
    end)
  end

  def all(_span), do: raise(ArgumentError, "expected PLL.Span")
end
