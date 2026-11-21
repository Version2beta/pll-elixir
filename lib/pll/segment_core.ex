defmodule PLL.SegmentCore do
  @moduledoc false
  # Exact integer timing for one immutable segment snapshot:
  # T(s) = anchor + (s - start) * pn / pd, with pn/pd a positive period in ns.
  # Slots passed in are always >= start; intermediate arithmetic is unbounded.

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
