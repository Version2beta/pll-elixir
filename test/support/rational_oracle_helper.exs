# complete; do not change
defmodule PLL.Test.RationalOracle do
  @moduledoc false
  # Deliberately unreduced fractions, raw factory terms, and binary-search due
  # boundaries: no production arithmetic or inverse-period helper is reused.
  @u 18_446_744_073_709_551_615
  @i 9_223_372_036_854_775_807
  def new(n, d), do: %{num: n, den: d, start: 0, anchor: 0, q: 0, cursor: 0}

  def exact(m, slot) do
    denominator = m.num * (1_000_000_000_000 + m.q)

    {m.anchor * denominator + (slot - m.start) * m.den * 1_000_000_000_000_000_000_000,
     denominator}
  end

  def floor(m, slot) do
    {n, d} = exact(m, slot)
    div(n, d)
  end

  def next(m) do
    {n, d} = exact(m, m.cursor)
    at = div(n + d - 1, d)
    if m.cursor == @u or at > @i, do: {:error, :overflow}, else: {:ok, {m.cursor, at}}
  end

  defp due?(m, slot, now) do
    {n, d} = exact(m, slot)
    n <= now * d
  end

  defp available(m, now) do
    cond do
      not due?(m, m.cursor, now) -> 0
      m.cursor == @u -> :overflow
      true -> search(m, now, m.cursor, @u - 1) - m.cursor + 1
    end
  end

  defp search(_m, _now, lo, hi) when lo == hi, do: lo

  defp search(m, now, lo, hi) do
    mid = div(lo + hi + 1, 2)
    if due?(m, mid, now), do: search(m, now, mid, hi), else: search(m, now, lo, mid - 1)
  end

  def step(m, {:claim, n}) do
    cond do
      n == 0 -> {:error, :invalid_argument}
      n > @u - m.cursor -> {:error, :overflow}
      floor(m, m.cursor + n - 1) > @i -> {:error, :overflow}
      true -> {:span, %{m | cursor: m.cursor + n}, {m.cursor, n, m}}
    end
  end

  def step(m, {:due, now, cap}) do
    cond do
      now < 0 or cap == 0 ->
        {:error, :invalid_argument}

      true ->
        case available(m, now) do
          :overflow ->
            {:error, :overflow}

          count ->
            n = min(count, cap)
            {:span, %{m | cursor: m.cursor + n}, {m.cursor, n, m}}
        end
    end
  end

  def step(m, {:skip, now, keep}) do
    if now < 0 do
      {:error, :invalid_argument}
    else
      case available(m, now) do
        :overflow ->
          {:error, :overflow}

        count ->
          n = max(0, count - keep)
          {:skip, %{m | cursor: m.cursor + n}, n}
      end
    end
  end

  def step(m, {:trim, q}) do
    cond do
      abs(q) >= 1_000_000_000_000 -> {:error, :invalid_argument}
      q == m.q -> {:trim, m}
      floor(m, m.cursor) > @i -> {:error, :overflow}
      true -> {:trim, %{m | start: m.cursor, anchor: floor(m, m.cursor), q: q}}
    end
  end

  def step(m, :next), do: next(m)
end
