defmodule PLLBench.Runner do
  @moduledoc "Sequential public-API throughput workloads; tool effects only."
  @names [:due_one, :due_batch, :claim, :skip, :span, :inlier, :window, :outlier, :step]
  @schema "pll-throughput-v1"
  @library_revision "03a99baca1db2872f6e6f9298914aab9e2242a2a"
  @rate_units_per_second 1_000_000_000
  @span_slots 64
  @units_per_op %{
    due_one: 1,
    due_batch: 64,
    claim: 1500,
    skip: 64,
    span: 64,
    inlier: 1,
    window: 1,
    outlier: 1,
    step: 1
  }

  def names, do: @names

  @doc "Prepare outside timing. Returns workload-owned initial state."
  @spec prepare(atom(), pos_integer()) :: term()
  def prepare(name, _iterations) when name in [:due_one, :due_batch, :claim, :skip],
    do: fresh_pacer()

  def prepare(:span, _iterations) do
    {:ok, _pacer, span} = PLL.Pacer.claim(fresh_pacer(), @span_slots)
    span
  end

  # n sets the outlier step_after, so the state depends on the iteration count.
  def prepare(name, iterations) when name in [:inlier, :window, :outlier, :step] do
    {:ok, rate} = PLL.Rate.units_per_second(@rate_units_per_second, 1)

    config = %{
      PLL.FollowerConfig.default(rate)
      | outlier_threshold_ns: 10,
        lock_threshold_ns: 10,
        window_ns: if(name == :window, do: 4, else: 0),
        step_after: if(name == :outlier, do: iterations + 1, else: 3)
    }

    {:ok, fresh} = PLL.Follower.new(config)
    {:ok, anchored, %{status: :anchored}} = PLL.Follower.observe(fresh, 0, 0)
    anchored
  end

  @doc "Chain n transitions; return %{calls, units, checksum, statuses, state}. No output."
  @spec execute(atom(), term(), pos_integer()) :: map()
  def execute(name, state, n) do
    initial = %{
      calls: 0,
      units: 0,
      checksum: 0,
      statuses: %{},
      state: state,
      cursor: initial_cursor(name, state)
    }

    result =
      Enum.reduce(1..n, initial, fn i, acc ->
        acc |> step(name, i) |> Map.update!(:calls, &(&1 + 1))
      end)

    Map.take(result, [:calls, :units, :checksum, :statuses, :state])
  end

  @doc "Check actual counts/status distribution, raising on a mislabeled workload."
  @spec validate!(atom(), map(), pos_integer()) :: :ok
  def validate!(name, %{calls: calls, units: units, statuses: statuses}, n) do
    expected = {n, n * Map.fetch!(@units_per_op, name), expected_statuses(name, n)}
    observed = {calls, units, statuses}

    if observed != expected do
      raise ArgumentError,
            "#{name}: expected {calls, units, statuses} #{inspect(expected)}, " <>
              "observed #{inspect(observed)}"
    end

    :ok
  end

  @doc "Prepare, snapshot, clock, execute, clock, snapshot, validate; retain sink in report.
  Clock returns ns. Snapshot returns %{memory_bytes, gc_count, reclaimed_words} (memory for self, GC VM-wide).
  Reclaimed words is VM-wide GC metadata, NOT allocation volume. No forced GC."
  @spec sample(atom(), pos_integer(), (-> integer()), (-> map())) :: map()
  def sample(name, n, clock, snapshot) do
    state = prepare(name, n)
    before = snapshot.()
    started = clock.()
    result = execute(name, state, n)
    finished = clock.()
    after_snapshot = snapshot.()
    :ok = validate!(name, result, n)

    elapsed_ns = finished - started

    if elapsed_ns <= 0 do
      raise ArgumentError, "measured elapsed time must be positive, got #{elapsed_ns} ns"
    end

    %{
      workload: name,
      calls: result.calls,
      units: result.units,
      checksum: result.checksum,
      statuses: result.statuses,
      elapsed_ns: elapsed_ns,
      process_memory_delta_bytes: after_snapshot.memory_bytes - before.memory_bytes,
      vm_gc_count_delta: after_snapshot.gc_count - before.gc_count,
      vm_reclaimed_words_delta: after_snapshot.reclaimed_words - before.reclaimed_words
    }
    |> Map.merge(PLLBench.Contract.metrics(elapsed_ns, result.calls, result.units))
  end

  @doc "Warm up each workload then print sequential samples and runtime/config labels."
  @spec main(PLLBench.Contract.config()) :: :ok
  def main(config) do
    IO.inspect(header(config), limit: :infinity, printable_limit: :infinity)

    for name <- @names do
      warm = execute(name, prepare(name, config.warmup), config.warmup)
      :ok = validate!(name, warm, config.warmup)

      for index <- 1..config.samples do
        report = sample(name, config.iterations, &monotonic_ns/0, &snapshot/0)
        IO.inspect(Map.put(report, :sample, index), limit: :infinity, printable_limit: :infinity)
      end
    end

    :ok
  end

  defp header(config) do
    %{
      schema: @schema,
      elixir: System.version(),
      otp: to_string(:erlang.system_info(:otp_release)),
      architecture: to_string(:erlang.system_info(:system_architecture)),
      online_schedulers: System.schedulers_online(),
      config: config,
      library_revision: @library_revision
    }
  end

  defp fresh_pacer do
    {:ok, rate} = PLL.Rate.units_per_second(@rate_units_per_second, 1)
    {:ok, pacer} = PLL.Pacer.new(rate)
    pacer
  end

  defp monotonic_ns, do: System.monotonic_time(:nanosecond)

  defp snapshot do
    {:memory, memory_bytes} = Process.info(self(), :memory)
    {gc_count, reclaimed_words, _} = :erlang.statistics(:garbage_collection)
    %{memory_bytes: memory_bytes, gc_count: gc_count, reclaimed_words: reclaimed_words}
  end

  # Only issuance workloads track the cursor: it gives first and count without reading spans.
  defp initial_cursor(name, state) when name in [:due_one, :due_batch, :claim] do
    {:ok, {cursor, _ceiling}} = PLL.Pacer.next_due(state)
    cursor
  end

  defp initial_cursor(_name, _state), do: nil

  defp step(acc, :due_one, i), do: issue(acc, PLL.Pacer.due(acc.state, i - 1, 1))
  defp step(acc, :due_batch, i), do: issue(acc, PLL.Pacer.due(acc.state, 64 * i - 1, 64))
  defp step(acc, :claim, _i), do: issue(acc, PLL.Pacer.claim(acc.state, 1500))

  defp step(acc, :skip, i) do
    {:ok, pacer, skipped} = PLL.Pacer.skip(acc.state, 64 * i - 1, 0)
    {:ok, {cursor, ceiling}} = PLL.Pacer.next_due(pacer)
    %{acc | state: pacer, units: acc.units + skipped, checksum: acc.checksum + cursor + ceiling}
  end

  # Full enumeration of the same immutable span; every tuple is generated and counted.
  defp step(acc, :span, _i) do
    {sum, count} =
      Enum.reduce(PLL.Span.all(acc.state), {0, 0}, fn {slot, ns}, {sum, count} ->
        {sum + slot + ns, count + 1}
      end)

    %{acc | units: acc.units + count, checksum: acc.checksum + sum}
  end

  defp step(acc, :inlier, i), do: observe(acc, 10 * i, 10 * i)
  defp step(acc, :window, i), do: observe(acc, i, i)
  defp step(acc, :outlier, i), do: observe(acc, 10 * i, 10 * i + 100)
  defp step(acc, :step, i), do: observe(acc, 10 * i, 10 * i + 100 * div(i + 2, 3))

  defp issue(acc, {:ok, pacer, _span}) do
    {:ok, {cursor, _ceiling}} = PLL.Pacer.next_due(pacer)
    first = acc.cursor
    count = cursor - first

    %{
      acc
      | state: pacer,
        cursor: cursor,
        units: acc.units + count,
        checksum: acc.checksum + first + count
    }
  end

  defp observe(acc, local, remote) do
    {:ok, follower, %{status: status, error_ns: error_ns}} =
      PLL.Follower.observe(acc.state, local, remote)

    %{
      acc
      | state: follower,
        units: acc.units + 1,
        checksum: acc.checksum + error_ns + local + remote,
        statuses: Map.update(acc.statuses, status, 1, &(&1 + 1))
    }
  end

  defp expected_statuses(:inlier, n), do: compact(%{accepted: n})

  defp expected_statuses(:window, n) do
    accepted = div(n - 1, 4)
    compact(%{accepted: accepted, pending: n - accepted})
  end

  defp expected_statuses(:outlier, n), do: compact(%{rejected: n})

  defp expected_statuses(:step, n) do
    stepped = div(n, 3)
    compact(%{stepped: stepped, rejected: n - stepped})
  end

  defp expected_statuses(_name, _n), do: %{}

  defp compact(statuses), do: Map.reject(statuses, fn {_status, count} -> count == 0 end)
end
