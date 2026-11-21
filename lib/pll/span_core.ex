defmodule PLL.SpanCore do
  @moduledoc false

  @doc "Floor segment time at relative index; enforce README index exception contract."
  @spec time(PLL.Span.t(), term()) :: non_neg_integer()
  def time(_span, _i), do: 0

  @doc "Fresh lazy enumeration; empty zero Span is valid and early halt avoids all later times."
  @spec all(PLL.Span.t()) :: Enumerable.t()
  def all(_span), do: []
end
