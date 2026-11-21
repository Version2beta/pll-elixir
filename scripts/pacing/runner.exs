defmodule PLLPacing.Runner do
  @moduledoc "Public-API-only bounded real-time pacing worker."
  alias PLLPacing.Contract
  alias PLL.{Pacer, Rate, Span}

  @batch_cap 4096
  @call_cap 1_000_000
  @offer_cap 1_000_000
  @progress_every 1_000_000_000

  @doc "Run validated config through injected now/wait/cancelled/write/progress functions. See SPEC."
  @spec run(map(), map()) :: map() | {:error, term()}
  def run(cfg, io) do
    case Contract.validate(cfg) do
      {:ok, cfg} -> start(cfg, io)
      {:error, _} = error -> error
    end
  end

  # Fresh chain: rate and pacer come only from public factories; each state is
  # a new immutable value that replaces the previous one.
  defp start(cfg, io) do
    with {:ok, rate} <- Rate.bits_per_second(cfg.bps, 8 * cfg.unit_bytes),
         {:ok, pacer} <- Pacer.new(rate) do
      group = if cfg.udp == :discard, do: 1, else: cfg.per_datagram

      ctx = %{
        cfg: cfg,
        io: io,
        deadline: cfg.seconds * 1_000_000_000,
        group: group,
        payload: :binary.copy(<<0>>, group * cfg.unit_bytes)
      }

      state = %{
        pacer: pacer,
        offered: 0,
        accepted_bytes: 0,
        due_calls: 0,
        send_calls: 0,
        max_batch: 0,
        lateness: [],
        pending: 0,
        last_progress: 0
      }

      loop(state, ctx)
    else
      {:error, _} -> {:error, :options}
    end
  end

  # Top of every call: cancellation, then deadline, then the call cap.
  defp loop(s, ctx) do
    if ctx.io.cancelled.() do
      finish(s, ctx, :cancel)
    else
      now = ctx.io.now.()

      cond do
        now >= ctx.deadline -> finish(s, ctx, :deadline)
        s.due_calls >= @call_cap -> finish(s, ctx, :cap)
        true -> due_batch(s, ctx, now)
      end
    end
  end

  defp due_batch(s, ctx, now) do
    case Pacer.due(s.pacer, now, @batch_cap) do
      {:ok, pacer, span} ->
        s = %{
          s
          | pacer: pacer,
            due_calls: s.due_calls + 1,
            max_batch: max(s.max_batch, span.count)
        }

        # Lateness is the oldest unit of a nonempty span, recorded before output.
        s =
          if span.count > 0,
            do: %{s | lateness: [now - Span.time(span, 0) | s.lateness]},
            else: s

        units(s, ctx, span.count, 0)

      {:error, error} ->
        {:error, {:pacer, error.code}}
    end
  end

  # Offers one unit at a time. Cancellation and the offer cap are checked before
  # each unit; the deadline is not, so an issued batch always completes.
  defp units(s, ctx, count, i) when i >= count, do: after_batch(s, ctx)

  defp units(s, ctx, count, i) do
    cond do
      ctx.io.cancelled.() ->
        finish(s, ctx, :cancel)

      s.offered >= @offer_cap ->
        finish(s, ctx, :cap)

      true ->
        s = %{s | offered: s.offered + 1, pending: s.pending + 1}

        if s.pending == ctx.group do
          case flush(%{s | pending: 0}, ctx, ctx.payload) do
            {:ok, s} -> units(s, ctx, count, i + 1)
            {:error, s, reason} -> finish(s, ctx, {:write_error, reason})
          end
        else
          units(s, ctx, count, i + 1)
        end
    end
  end

  # After a batch: optional progress, then wait until the earlier of next due and
  # deadline. A non-positive remainder drains another batch without waiting.
  defp after_batch(s, ctx) do
    s = maybe_progress(s, ctx)
    now = ctx.io.now.()

    case Pacer.next_due(s.pacer) do
      {:ok, {_cursor, ceiling}} ->
        remaining = min(ceiling - now, ctx.deadline - now)

        if remaining > 0,
          do: wait(s, ctx, div(remaining + 999_999, 1_000_000)),
          else: loop(s, ctx)

      {:error, error} ->
        {:error, {:pacer, error.code}}
    end
  end

  defp wait(s, ctx, ms) do
    case ctx.io.wait.(ms) do
      :ok -> loop(s, ctx)
      :cancelled -> finish(s, ctx, :cancel)
    end
  end

  defp maybe_progress(s, ctx) do
    now = ctx.io.now.()

    if now - s.last_progress >= @progress_every do
      ctx.io.progress.(%{
        elapsed_ns: now,
        offered: s.offered,
        accepted_bytes: s.accepted_bytes,
        due_calls: s.due_calls,
        send_calls: s.send_calls
      })

      %{s | last_progress: now}
    else
      s
    end
  end

  # Normal deadline flushes the partial group inside elapsed time. Every other
  # stop discards buffered units without writing them.
  defp finish(s, ctx, :deadline) do
    case flush_partial(s, ctx) do
      {:ok, s} -> report(s, ctx, :deadline)
      {:error, s, reason} -> report(s, ctx, {:write_error, reason})
    end
  end

  defp finish(s, ctx, stop), do: report(%{s | pending: 0}, ctx, stop)

  defp report(s, ctx, stop) do
    elapsed = ctx.io.now.()

    case Pacer.next_due(s.pacer) do
      {:ok, {_cursor, ceiling}} ->
        r =
          Map.take(s, [:offered, :accepted_bytes, :due_calls, :send_calls, :max_batch, :lateness])

        Contract.report(Map.put(r, :stop, stop), ctx.cfg, elapsed, ceiling)

      {:error, error} ->
        {:error, {:pacer, error.code}}
    end
  end

  defp flush_partial(%{pending: 0} = s, _ctx), do: {:ok, s}

  defp flush_partial(s, ctx) do
    bytes = binary_part(ctx.payload, 0, s.pending * ctx.cfg.unit_bytes)
    flush(%{s | pending: 0}, ctx, bytes)
  end

  # Counts the attempt, then the writer's actual bytes, even on error. Short
  # success and invalid writer results are errors; nothing is retried.
  defp flush(s, ctx, bytes) do
    expected = byte_size(bytes)
    s = %{s | send_calls: s.send_calls + 1}

    case ctx.io.write.(bytes) do
      {:ok, n} when is_integer(n) and n == expected ->
        {:ok, add_accepted(s, n)}

      {:ok, n} when is_integer(n) and n >= 0 and n < expected ->
        {:error, add_accepted(s, n), :short_write}

      {:error, n, reason} when is_integer(n) and n >= 0 and n <= expected ->
        {:error, add_accepted(s, n), reason}

      _ ->
        {:error, s, :invalid_writer_result}
    end
  end

  defp add_accepted(s, n), do: %{s | accepted_bytes: s.accepted_bytes + n}
end
