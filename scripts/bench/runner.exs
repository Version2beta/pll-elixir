defmodule PLLBench.Runner do
  @moduledoc "Sequential public-API throughput workloads; tool effects only."
  @names [:due_one, :due_batch, :claim, :skip, :span, :inlier, :window, :outlier, :step]
  def names, do: @names

  @doc "Prepare outside timing. Returns workload-owned initial state."
  @spec prepare(atom(), pos_integer()) :: term()
  def prepare(_name, _iterations), do: nil

  @doc "Chain n transitions; return %{calls, units, checksum, statuses, state}. No output."
  @spec execute(atom(), term(), pos_integer()) :: map()
  def execute(_name, _state, _n),
    do: %{calls: 0, units: 0, checksum: 0, statuses: %{}, state: nil}

  @doc "Check actual counts/status distribution, raising on a mislabeled workload."
  @spec validate!(atom(), map(), pos_integer()) :: :ok
  def validate!(_name, _result, _n), do: :ok

  @doc "Prepare, snapshot, clock, execute, clock, snapshot, validate; retain sink in report.
  Clock returns ns. Snapshot returns %{memory_bytes, gc_count, reclaimed_words} (memory for self, GC VM-wide).
  Reclaimed words is VM-wide GC metadata, NOT allocation volume. No forced GC."
  @spec sample(atom(), pos_integer(), (-> integer()), (-> map())) :: map()
  def sample(_name, _n, _clock, _snapshot), do: %{}

  @doc "Warm up each workload then print sequential samples and runtime/config labels."
  @spec main(PLLBench.Contract.config()) :: :ok
  def main(_config), do: :ok
end
