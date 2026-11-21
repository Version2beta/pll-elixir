defmodule PLL.PacerCore do
  @moduledoc false

  alias PLL.SegmentCore

  # README envelopes: slot/count/cap in 0..U; pacer time in signed 64-bit range.
  @u 18_446_744_073_709_551_615
  @imin -9_223_372_036_854_775_808
  @imax 9_223_372_036_854_775_807
  @trim_limit 1_000_000_000_000

  @doc "Initialize a valid reduced Rate at slot/time/trim zero; wrong kind raises ArgumentError."
  @spec new(PLL.Rate.t()) :: {:ok, PLL.Pacer.t()} | {:error, PLL.Error.t()}
  def new(%PLL.Rate{num: num, den: den} = rate) when num > 0 and den > 0 do
    segment = SegmentCore.new(num, den, 0, 0, 0)
    {:ok, %PLL.Pacer{rate: rate, cursor: 0, segment: segment}}
  end

  def new(%PLL.Rate{}), do: error(:invalid_rate)
  def new(_rate), do: raise(ArgumentError, "expected PLL.Rate")

  @doc "Exact due comparison, cap and immutable transition; README validation and U rules."
  @spec due(PLL.Pacer.t(), term(), term()) :: PLL.Pacer.result()
  def due(%PLL.Pacer{} = pacer, now_ns, max_count) do
    with {:ok, now} <- time_arg(now_ns),
         {:ok, cap} <- count_arg(max_count) do
      cond do
        now < 0 or cap == 0 ->
          error(:invalid_argument)

        cursor_due?(pacer, now) ->
          error(:overflow)

        true ->
          count = min(due_count(pacer, now), cap)
          {:ok, %{pacer | cursor: pacer.cursor + count}, span(pacer, count)}
      end
    end
  end

  def due(_pacer, _now_ns, _max_count), do: not_pacer!()

  @doc "Claim positive uint64 n, checking last floor and cursor envelope, without enumeration."
  @spec claim(PLL.Pacer.t(), term()) :: PLL.Pacer.result()
  def claim(%PLL.Pacer{cursor: cursor, segment: segment} = pacer, n) do
    with {:ok, count} <- count_arg(n) do
      cond do
        count == 0 -> error(:invalid_argument)
        count > @u - cursor -> error(:overflow)
        SegmentCore.floor_time(segment, cursor + count - 1) > @imax -> error(:overflow)
        true -> {:ok, %{pacer | cursor: cursor + count}, span(pacer, count)}
      end
    end
  end

  def claim(_pacer, _n), do: not_pacer!()

  @doc "Skip due slots except newest keep, with exact due comparison and immutable transition."
  @spec skip(PLL.Pacer.t(), term(), term()) ::
          {:ok, PLL.Pacer.t(), non_neg_integer()} | {:error, PLL.Error.t()}
  def skip(%PLL.Pacer{} = pacer, now_ns, keep) do
    with {:ok, now} <- time_arg(now_ns),
         {:ok, retain} <- count_arg(keep) do
      cond do
        now < 0 ->
          error(:invalid_argument)

        cursor_due?(pacer, now) ->
          error(:overflow)

        true ->
          available = due_count(pacer, now)
          skipped = available - min(available, retain)
          {:ok, %{pacer | cursor: pacer.cursor + skipped}, skipped}
      end
    end
  end

  def skip(_pacer, _now_ns, _keep), do: not_pacer!()

  @doc "Return cursor and exact ceiling, or overflow; never enumerate slots."
  @spec next_due(PLL.Pacer.t()) ::
          {:ok, {non_neg_integer(), non_neg_integer()}} | {:error, PLL.Error.t()}
  def next_due(%PLL.Pacer{cursor: cursor, segment: segment}) do
    ceiling = SegmentCore.ceil_time(segment, cursor)

    cond do
      cursor == @u -> error(:overflow)
      ceiling > @imax -> error(:overflow)
      true -> {:ok, {cursor, ceiling}}
    end
  end

  def next_due(_pacer), do: not_pacer!()

  @doc "Validate signed trim, same-trim no-op, otherwise floor re-anchor preserving issued spans."
  @spec set_trim(PLL.Pacer.t(), term()) :: {:ok, PLL.Pacer.t()} | {:error, PLL.Error.t()}
  def set_trim(%PLL.Pacer{segment: %PLL.Segment{trim: trim}} = pacer, ppt) do
    with {:ok, value} <- trim_arg(ppt) do
      cond do
        abs(value) >= @trim_limit -> error(:invalid_argument)
        value == trim -> {:ok, pacer}
        true -> retrim(pacer, value)
      end
    end
  end

  def set_trim(_pacer, _ppt), do: not_pacer!()

  # New segment starts at the cursor, anchored at the floor of the old timing there.
  defp retrim(%PLL.Pacer{rate: %PLL.Rate{num: num, den: den}} = pacer, value) do
    %PLL.Pacer{cursor: cursor, segment: segment} = pacer
    anchor = SegmentCore.floor_time(segment, cursor)

    if anchor > @imax do
      error(:overflow)
    else
      {:ok, %{pacer | segment: SegmentCore.new(num, den, cursor, anchor, value)}}
    end
  end

  @doc "Current integer ppt; wrong state kind raises ArgumentError."
  @spec trim(PLL.Pacer.t()) :: integer()
  def trim(%PLL.Pacer{segment: %PLL.Segment{trim: trim}}), do: trim
  def trim(_pacer), do: not_pacer!()

  # Scalars are checked for type, then envelope, before any semantic check.
  defp time_arg(v) when is_integer(v) and v >= @imin and v <= @imax, do: {:ok, v}
  defp time_arg(v) when is_integer(v), do: error(:overflow)
  defp time_arg(_v), do: error(:invalid_argument)

  defp count_arg(v) when is_integer(v) and v >= 0 and v <= @u, do: {:ok, v}
  defp count_arg(v) when is_integer(v), do: error(:overflow)
  defp count_arg(_v), do: error(:invalid_argument)

  defp trim_arg(v) when is_integer(v) and v >= @imin and v <= @imax, do: {:ok, v}
  defp trim_arg(v) when is_integer(v), do: error(:overflow)
  defp trim_arg(_v), do: error(:invalid_argument)

  # Number of slots due at now_ns that the cursor has not passed, ignoring any
  # cap and excluding slot U. Computed arithmetically, never enumerated.
  defp due_count(%PLL.Pacer{cursor: cursor, segment: segment}, now_ns) do
    case SegmentCore.last_due(segment, now_ns) do
      nil -> 0
      last -> max(min(last, @u - 1) - cursor + 1, 0)
    end
  end

  # Only the cursor slot U can be an overflow: it may be neither issued nor skipped.
  defp cursor_due?(%PLL.Pacer{cursor: @u, segment: segment}, now_ns) do
    case SegmentCore.last_due(segment, now_ns) do
      nil -> false
      last -> last >= @u
    end
  end

  defp cursor_due?(_pacer, _now_ns), do: false

  defp span(%PLL.Pacer{cursor: cursor, segment: segment}, count) do
    %PLL.Span{first: cursor, count: count, segment: segment}
  end

  defp error(code), do: {:error, %PLL.Error{code: code}}

  defp not_pacer!, do: raise(ArgumentError, "expected PLL.Pacer")
end
