Code.require_file("../../scripts/bench/contract.exs", __DIR__)
Code.require_file("../../scripts/bench/runner.exs", __DIR__)

defmodule PLLBench.RunnerTest do
  use ExUnit.Case
  alias PLLBench.{Contract, Runner}
  import ExUnit.CaptureIO

  test "bounded positive options, duplicate and unknown rejection" do
    assert {:ok, %{iterations: 1000, samples: 3, warmup: 100}} = Contract.parse([])
    assert {:ok, %{iterations: 12, samples: 2, warmup: 4}} = Contract.parse(["--smoke"])

    assert {:ok, %{iterations: 10_000, samples: 10, warmup: 1}} =
             Contract.parse(["--iterations", "10000", "--samples", "10", "--warmup", "1"])

    for args <- [
          ["--wat", "1"],
          ["--samples", "11"],
          ["--iterations", "10001"],
          ["--warmup", "0"],
          ["--samples", "-1"],
          ["--samples", "1x"],
          ["--samples"],
          ["--smoke", "--samples", "1"],
          ["--samples", "1", "--samples", "2"],
          ["--iterations", String.duplicate("9", 1000)]
        ] do
      assert {:error, _} = Contract.parse(args)
    end
  end

  test "exact metric arithmetic" do
    assert %{ns_per_op: 50.0, ops_per_s: 20_000_000.0, units_per_s: 1_280_000_000.0} =
             Contract.metrics(100, 2, 128)
  end

  test "all nine workloads chain real public API state and validate observed statuses" do
    assert Runner.names() == [
             :due_one,
             :due_batch,
             :claim,
             :skip,
             :span,
             :inlier,
             :window,
             :outlier,
             :step
           ]

    for name <- Runner.names(), n <- [1, 4, 12, 17] do
      state = Runner.prepare(name, n)
      r = Runner.execute(name, state, n)
      assert r.calls == n
      assert r.units > 0
      assert r.checksum != 0

      expected_statuses =
        case name do
          :inlier -> %{accepted: n}
          :window -> %{accepted: div(n - 1, 4), pending: n - div(n - 1, 4)}
          :outlier -> %{rejected: n}
          :step -> %{stepped: div(n, 3), rejected: n - div(n, 3)}
          _ -> %{}
        end
        |> Enum.reject(fn {_, count} -> count == 0 end)
        |> Map.new()

      assert r.statuses == expected_statuses
      assert :ok = Runner.validate!(name, r, n)
      assert_raise MatchError, fn -> Runner.validate!(name, %{r | units: 0}, n) end
      assert_raise MatchError, fn -> Runner.validate!(name, %{r | statuses: %{bogus: n}}, n) end

      if name in [:due_one, :due_batch, :claim, :skip] do
        assert {:ok, {cursor, _}} = PLL.Pacer.next_due(r.state)
        assert cursor == r.units
        assert {:ok, {0, 0}} = PLL.Pacer.next_due(state)
      end

      if name in [:inlier, :window, :outlier, :step], do: assert(r.state != state)
    end
  end

  test "span checksum forces tuple enumeration separately from issuance" do
    r = Runner.execute(:span, Runner.prepare(:span, 3), 3)
    assert r.checksum == 3 * 4032
    assert r.units == 192
  end

  test "sample arithmetic uses fake ns clock and explicit memory/VM GC scopes" do
    Process.put(:ticks, [100, 300])

    Process.put(:snapshots, [
      %{memory_bytes: 100, gc_count: 2, reclaimed_words: 20},
      %{memory_bytes: 80, gc_count: 5, reclaimed_words: 120}
    ])

    pop = fn key ->
      [h | t] = Process.get(key)
      Process.put(key, t)
      h
    end

    r = Runner.sample(:due_batch, 2, fn -> pop.(:ticks) end, fn -> pop.(:snapshots) end)
    assert r.elapsed_ns == 200
    assert r.calls == 2 and r.units == 128
    assert r.ns_per_op == 100.0 and r.ops_per_s == 10_000_000.0
    assert r.units_per_s == 640_000_000.0
    assert r.process_memory_delta_bytes == -20
    assert r.vm_gc_count_delta == 3 and r.vm_reclaimed_words_delta == 100
    assert r.checksum > 0
  end

  test "finite real timed smoke outputs all samples without timing thresholds" do
    output =
      capture_io(fn -> assert :ok = Runner.main(%{iterations: 12, samples: 2, warmup: 4}) end)

    assert output =~ "library_revision"
    assert output =~ "platform"
    assert length(Regex.scan(~r/elapsed_ns:/, output)) == 18
    assert length(Regex.scan(~r/checksum:/, output)) == 18
    for name <- Runner.names(), do: assert(output =~ "workload: :#{name}")
  end
end
