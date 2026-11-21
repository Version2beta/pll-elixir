Code.require_file("../../scripts/pacing/contract.exs", __DIR__)
Code.require_file("../../scripts/pacing/runner.exs", __DIR__)
Code.require_file("../../scripts/pacing/runtime.exs", __DIR__)

defmodule PLLPacing.RunnerTest do
  use ExUnit.Case
  alias PLLPacing.{Contract, Runner, Runtime}

  defp config(overrides \\ %{}) do
    {:ok, cfg} = Contract.parse([])
    Map.merge(cfg, Map.merge(%{seconds: 1, bps: 8, unit_bytes: 1}, overrides))
  end

  defp fake(opts \\ []) do
    Process.put(:time, Keyword.get(opts, :start, 0))
    Process.put(:writes, [])
    Process.put(:waits, [])
    Process.put(:cancel_calls, 0)

    %{
      now: fn -> Process.get(:time) end,
      wait: fn ms ->
        Process.put(:waits, [ms | Process.get(:waits)])
        Process.put(:time, Process.get(:time) + ms * 1_000_000)
        Keyword.get(opts, :wait_result, :ok)
      end,
      cancelled: fn ->
        n = Process.get(:cancel_calls) + 1
        Process.put(:cancel_calls, n)
        n > Keyword.get(opts, :cancel_after, 2_000_000)
      end,
      write: fn bytes ->
        Process.put(:writes, [bytes | Process.get(:writes)])
        Process.put(:time, Process.get(:time) + Keyword.get(opts, :write_delay, 0))
        Keyword.get(opts, :write_result, {:ok, byte_size(bytes)})
      end,
      progress: fn _ -> :ok end
    }
  end

  test "parser defaults and all scalar/product/work bounds before effects" do
    assert {:ok, %{bps: 19_392_658, unit_bytes: 188, seconds: 5}} = Contract.parse([])

    for args <- [
          ["--bps", "0"],
          ["--bps", "100000001"],
          ["--unit-bytes", "65508"],
          ["--seconds", "11"],
          ["--seconds", "0.1"],
          ["--seconds", "01"],
          ["--per-datagram", "0"],
          ["--per-datagram", "349"],
          ["--udp", "remote:9"],
          ["--udp", "discard"],
          ["--bps", "1", "--bps", "2"],
          ["--bps"],
          ["--mode", "ticker"],
          ["--find-max"],
          ["--bps", String.duplicate("1", 1000)],
          ["--bps", "100000000", "--unit-bytes", "1"]
        ] do
      assert {:error, :options} = Contract.parse(args), inspect(args)
    end

    for cfg <- [
          config(%{seconds: :bad}),
          config(%{unit_bytes: -1}),
          config(%{bps: 0}),
          config(%{extra: 1})
        ] do
      assert {:error, :options} = Runtime.execute(cfg, fn _, _ -> flunk("effects") end)
      assert {:error, :options} = Runner.run(cfg, %{})
    end

    assert {:ok, _} =
             Contract.parse([
               "--bps",
               "1",
               "--unit-bytes",
               "65507",
               "--per-datagram",
               "1",
               "--seconds",
               "10"
             ])
  end

  test "Go quantile floor rule and independent report arithmetic/thresholds" do
    assert Contract.quantile([], 0.99) == 0
    assert Contract.quantile([1, 2], 0.99) == 1
    assert Contract.quantile(Enum.to_list(0..99), 0.99) == 98

    r = %{
      offered: 1,
      accepted_bytes: 1,
      due_calls: 2,
      send_calls: 1,
      max_batch: 1,
      lateness: [5_000_000],
      stop: :deadline
    }

    a = Contract.report(r, config(), 1_000_000_000, 995_000_000)
    assert a.sustained and a.demonstration_pass
    assert a.writer_mbps == 0.000008 and a.average_batch == 0.5
    refute Contract.report(r, config(), 1_000_000_001, 995_000_000).sustained
    refute Contract.report(%{r | offered: 0}, config(), 1, 1).sustained
    refute Contract.report(%{r | stop: :cancel}, config(), 1_000_000_000, 1_000_000_000).sustained

    refute Contract.report(%{r | accepted_bytes: 0}, config(), 1_000_000_000, 1_000_000_000).demonstration_pass
  end

  test "slot zero, chained state, low rate deadline and discard ignores grouping" do
    r = Runner.run(config(%{bps: 1, per_datagram: 7}), fake())

    assert %{
             offered: 1,
             accepted_bytes: 1,
             due_calls: 1,
             send_calls: 1,
             elapsed_ns: 1_000_000_000,
             backlog_ns: 0,
             max_batch: 1,
             stop: :deadline,
             median_ns: 0
           } = r

    assert Process.get(:waits) == [1000]
    assert Process.get(:writes) == [<<0>>]
    r = Runner.run(config(%{bps: 24}), fake())
    assert r.offered == 3 and r.due_calls == 3 and r.send_calls == 3
    assert r.elapsed_ns == 1_000_000_000
    assert Process.get(:waits) == [333, 333, 334]
  end

  test "coarse batching, exact oldest lateness and capped catchup without skip" do
    r = Runner.run(config(%{bps: 80_000}), fake(start: 900_000_000))
    assert r.max_batch == 4096
    assert r.offered == 9991
    assert r.max_ns == 900_000_000
    assert r.accepted_bytes == r.offered
    assert r.due_calls > 3 and r.stop == :deadline
    refute r.sustained
  end

  test "grouping seven and final partial flush counted inside time/backlog" do
    r =
      Runner.run(
        config(%{bps: 24, udp: :loopback, per_datagram: 7}),
        fake(write_delay: 20_000_000)
      )

    assert r.offered == 3 and r.accepted_bytes == 3 and r.send_calls == 1
    assert r.elapsed_ns == 1_020_000_000 and r.backlog_ns == 20_000_000
    assert Process.get(:writes) == [<<0, 0, 0>>]
    r = Runner.run(config(%{bps: 80, udp: :loopback, per_datagram: 7}), fake())
    assert r.offered == 10 and r.send_calls == 2
    assert Enum.map(Enum.reverse(Process.get(:writes)), &byte_size/1) == [7, 3]
  end

  test "writer errors and short writes count actual bytes, no retries or final carry" do
    for {result, accepted, reason} <- [
          {{:error, 0, :broken}, 0, :broken},
          {{:error, 1, :broken}, 1, :broken},
          {{:ok, 1}, 1, :short_write}
        ] do
      r = Runner.run(config(%{unit_bytes: 2}), fake(write_result: result))
      assert r.offered == 1 and r.accepted_bytes == accepted and r.send_calls == 1
      assert r.stop == {:write_error, reason}
      refute r.sustained
    end

    r =
      Runner.run(
        config(%{bps: 24, udp: :loopback, per_datagram: 7}),
        fake(write_result: {:error, 2, :flush})
      )

    assert r.stop == {:write_error, :flush} and r.accepted_bytes == 2 and r.offered == 3
    assert Runner.run(config(), fake()).accepted_bytes == 1
  end

  test "cancel before call, between units and during wait discards partial buffers" do
    assert Runner.run(config(), fake(cancel_after: 0)).offered == 0

    r =
      Runner.run(
        config(%{bps: 80, udp: :loopback, per_datagram: 7}),
        fake(start: 900_000_000, cancel_after: 3)
      )

    assert r.stop == :cancel and r.offered == 2 and r.accepted_bytes == 0 and r.send_calls == 0
    r = Runner.run(config(), fake(wait_result: :cancelled))
    assert r.stop == :cancel and r.offered == 1
  end

  test "deadline finishes already issued batch, not an extra call" do
    r = Runner.run(config(%{bps: 80}), fake(start: 900_000_000, write_delay: 20_000_000))
    assert r.offered == 10 and r.due_calls == 1 and r.elapsed_ns == 1_100_000_000
    assert r.backlog_ns == 100_000_000
  end

  test "hard call cap stops a frozen fake clock instead of spinning forever" do
    io = %{fake() | wait: fn _ -> :ok end}
    r = Runner.run(config(), io)
    assert r.stop == :cap and r.due_calls == 1_000_000 and r.offered == 1
    assert r.send_calls == 1 and r.lateness_samples == 1
    refute r.sustained
  end

  test "all approved ATSC command configurations use exact rational schedule and grouping" do
    for args <- [
          [],
          ["--udp", "loopback", "--per-datagram", "1"],
          ["--udp", "loopback", "--per-datagram", "7"]
        ] do
      {:ok, cfg} = Contract.parse(args)
      r = Runner.run(cfg, fake())
      expected = div(4_999_000_000 * 19_392_658, 1_000_000_000 * 188 * 8) + 1
      assert r.offered == expected
      assert r.accepted_bytes == expected * 188
      per = if cfg.udp == :discard, do: 1, else: cfg.per_datagram
      assert r.send_calls == div(expected + per - 1, per)
      assert r.elapsed_ns == 5_000_000_000
      assert r.demonstration_pass
      assert r.p99_ns < 1_000_000
    end
  end

  test "monitored discard worker cleanup on success and exception; guard and linked owner cleanup" do
    parent = self()

    assert :finished =
             Runtime.execute(config(), fn _, _ ->
               send(parent, {:worker, self()})
               :finished
             end)

    assert_receive {:worker, pid}
    refute Process.alive?(pid)

    assert {:error, {:exception, "broken"}} =
             Runtime.execute(config(), fn _, _ ->
               send(parent, {:worker, self()})
               raise "broken"
             end)

    assert_receive {:worker, pid}
    refute Process.alive?(pid)

    {pid, ref} =
      spawn_monitor(fn ->
        receive do
          :never -> :ok
        end
      end)

    assert {:error, :guard} = Runtime.await(pid, ref, 0)
    refute Process.alive?(pid)

    assert {:error, {:worker_exit, :boom}} =
             Runtime.execute(config(), fn _, _ -> Process.exit(self(), :boom) end)

    {owner, owner_ref} =
      spawn_monitor(fn ->
        child =
          spawn_link(fn ->
            receive do
              :never -> :ok
            end
          end)

        send(parent, {:child, child})

        receive do
          :never -> :ok
        end
      end)

    assert_receive {:child, child}
    child_ref = Process.monitor(child)
    assert {:error, :guard} = Runtime.await(owner, owner_ref, 0)
    assert_receive {:DOWN, ^child_ref, :process, ^child, :killed}
    refute Process.alive?(child)

    assert :cancelled =
             Runtime.execute(config(), fn _, io ->
               assert io.now.() >= 0
               send(self(), :cancel)
               io.wait.(1)
             end)

    pid =
      spawn_link(fn ->
        receive do
          :never -> :ok
        end
      end)

    assert :ok = Runtime.stop_linked(pid)
    refute Process.alive?(pid)
  end
end
