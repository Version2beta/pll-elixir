defmodule PLL.SegmentCore do
  @moduledoc false
  # Exact integer timing for one immutable segment snapshot:
  # T(s) = anchor + (s - start) * pn / pd, with pn/pd a positive period in ns.
  # Slots passed in are always >= start; intermediate arithmetic is unbounded.

  @unit 1_000_000_000_000
  @scale 1_000_000_000_000_000_000_000

  @doc "Exact segment of slot period den*10^21/(num*(10^12+trim)) ns, reduced; anchored at start/anchor."
  @spec new(pos_integer(), pos_integer(), non_neg_integer(), non_neg_integer(), integer()) ::
          PLL.Segment.t()
  def new(num, den, start, anchor, trim) do
    pn = den * @scale
    pd = num * (@unit + trim)
    g = Integer.gcd(pn, pd)
    %PLL.Segment{start: start, anchor: anchor, trim: trim, pn: div(pn, g), pd: div(pd, g)}
  end

  @doc "Floor of the exact time of slot."
  @spec floor_time(PLL.Segment.t(), non_neg_integer()) :: non_neg_integer()
  def floor_time(%PLL.Segment{start: start, anchor: anchor, pn: pn, pd: pd}, slot) do
    anchor + div((slot - start) * pn, pd)
  end

  @doc "Ceiling of the exact time of slot."
  @spec ceil_time(PLL.Segment.t(), non_neg_integer()) :: non_neg_integer()
  def ceil_time(%PLL.Segment{start: start, anchor: anchor, pn: pn, pd: pd}, slot) do
    anchor + div((slot - start) * pn + pd - 1, pd)
  end

  @doc "Largest slot whose exact time is <= now_ns, or nil when no slot is due."
  @spec last_due(PLL.Segment.t(), integer()) :: integer() | nil
  def last_due(%PLL.Segment{start: start, anchor: anchor, pn: pn, pd: pd}, now_ns)
      when now_ns >= anchor do
    start + div((now_ns - anchor) * pd, pn)
  end

  def last_due(%PLL.Segment{}, _now_ns), do: nil
end
