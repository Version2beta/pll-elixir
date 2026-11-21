Code.require_file("../support/history_oracle_helper.exs", __DIR__)
Code.require_file("../support/follower_equation_oracle_helper.exs", __DIR__)

defmodule PLL.FollowerSyntheticTest do
  use ExUnit.Case, async: true
  alias PLL.{Follower, FollowerConfig, Rate, Pacer, HistoryOracle}

  test "independent integer history model across seeded windows jumps and invalid retries" do
    {:ok, rate} = Rate.units_per_second(1_000_000_000, 1)

    for window <- [0, 7, 25] do
      {:ok, f} =
        Follower.new(%{
          FollowerConfig.default(rate)
          | window_ns: window,
            bandwidth_hz: 1.0e-300,
            damping: 1.0e-300,
            outlier_threshold_ns: 10,
            holdover_after_ns: 50,
            lock_count: 10000
        })

      {_, _, counts} =
        Enum.reduce(0..400, {f, HistoryOracle.new(window), %{}}, fn k, {f, m, counts} ->
          l = k * 10
          r = k * 10 + div(k, 70) * 100 + rem(k * 7919, 19)
          {n, status, e} = HistoryOracle.read(m, l, r)

          f =
            if status == :order do
              assert {:error, %{code: :order}} = Follower.observe(f, l, r)
              f
            else
              assert {:ok, next, %{status: ^status, error_ns: ^e}} = Follower.observe(f, l, r)
              assert Follower.local(next, r) == {:ok, r + n.shift}

              assert Follower.state(next, l) ==
                       {:ok, if(l - n.accepted > 50, do: :holdover, else: :acquiring)}

              next
            end

          counts = Map.update(counts, status, 1, &(&1 + 1))

          counts =
            if k > 0 do
              # Replay is an explicit invalid retry, compared to the independent model.
              assert {^n, :order, 0} = HistoryOracle.read(n, l, r)
              assert {:error, %{code: :order}} = Follower.observe(f, l, r)
              Map.update(counts, :order, 1, &(&1 + 1))
            else
              counts
            end

          {f, n, counts}
        end)

      assert counts.anchored == 1
      assert counts.accepted > 100
      assert counts.rejected >= 15
      assert counts.stepped >= 5
      assert counts.order > 0

      if window == 0,
        do: assert(Map.get(counts, :pending, 0) == 0),
        else: assert(counts.pending > 0)
    end
  end

  test "synthetic drift jitter jump outage recovery and follower driven pacer" do
    {:ok, rate} = Rate.units_per_second(1000, 1)
    c = FollowerConfig.default(rate)
    {:ok, f} = Follower.new(c)
    {:ok, f, _} = Follower.observe(f, 0, 0)
    {:ok, p} = Pacer.new(rate)

    {f, p, counts, _, _} =
      Enum.reduce(1..1200, {f, p, %{}, PLL.FollowerEquationOracle.anchor(0, 0), []}, fn k,
                                                                                        {f, p,
                                                                                         counts,
                                                                                         model,
                                                                                         run} ->
        # No sleeping/clocks: deterministic increasing drift and bounded jitter.
        # A 2-second phase jump exercises rejected/rejected/stepped recovery.
        outage = if k >= 600, do: 7_000_000_000, else: 0
        jump = if k >= 300, do: 2000, else: 0
        l = k * 10_000_000 + outage + rem(k * 7919, 10001)
        r = round((l - outage) / 1.0e6 * (1 + 40.0e-6 + k * 1.0e-8)) + jump
        if k == 600, do: assert(Follower.state(f, l) == {:ok, :holdover})
        assert {:ok, n, o} = Follower.observe(f, l, r)
        e = l - model.a - model.frac - (r - model.r) * 1.0e6 / (1 + model.y)

        {model, run, expected} =
          if abs(e) > c.outlier_threshold_ns do
            run =
              if run != [] and abs(e - hd(run)) <= c.outlier_threshold_ns,
                do: run ++ [e],
                else: [e]

            if length(run) == c.step_after do
              {%{PLL.FollowerEquationOracle.anchor(l, r) | y: model.y}, [], :stepped}
            else
              {model, run, :rejected}
            end
          else
            {updated, _} =
              PLL.FollowerEquationOracle.update(
                model,
                l,
                r,
                1.0e6,
                c.bandwidth_hz,
                c.damping,
                0.0005
              )

            {updated, [], :accepted}
          end

        assert o.status == expected
        assert abs(o.error_ns - round(e)) <= 1
        assert abs(Follower.offset(n) - model.y) <= 1.0e-12
        assert {:ok, mapped} = Follower.local(n, r + 17)
        assert abs(mapped - PLL.FollowerEquationOracle.local(model, r + 17, 1.0e6)) <= 1
        assert abs(Follower.offset(n)) <= 0.0005
        assert {:ok, p} = Pacer.set_trim(p, Follower.trim(n))
        assert {:ok, p, s} = Pacer.due(p, l, 10000)
        assert s.count > 0
        {n, p, Map.update(counts, o.status, 1, &(&1 + 1)), model, run}
      end)

    assert counts.stepped >= 2
    assert counts.rejected >= 4
    assert counts.accepted > 1100
    assert {:ok, _} = Pacer.next_due(p)
    assert Follower.state(f, 19_000_000_000) != {:ok, :holdover}
  end
end
