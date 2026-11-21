defmodule PLL.FollowerHistoryTest do
  use ExUnit.Case, async: true
  alias PLL.{Follower, FollowerConfig, Rate, Error}
  @hi 9_223_372_036_854_775_807
  @lo -9_223_372_036_854_775_808
  defp fresh(opts), do: fresh(opts, 0, 0)

  defp fresh(opts, l, r) do
    {:ok, rate} = Rate.units_per_second(1_000_000_000, 1)
    {:ok, f} = Follower.new(Map.merge(FollowerConfig.default(rate), opts))
    {:ok, f, %{status: :anchored}} = Follower.observe(f, l, r)
    f
  end

  defp read(f, l, r, status, e) do
    assert {:ok, n, %{status: ^status, error_ns: ^e}} = Follower.observe(f, l, r)
    n
  end

  test "signed minimum window candidate, ties and half-open boundary" do
    f = fresh(%{window_ns: 10, bandwidth_hz: 1.0e308, damping: 1.0, holdover_after_ns: 10})
    # +5
    f = read(f, 10, 5, :pending, 0)
    # -9, smaller signed not absolute
    f = read(f, 11, 20, :pending, 0)
    # -9 tie keeps earlier
    f = read(f, 12, 21, :pending, 0)
    assert Follower.local(f, 20) == {:ok, 20}
    f = read(f, 20, 22, :accepted, -9)
    assert Follower.local(f, 20) == {:ok, 11}
    assert Follower.state(f, 21) != {:ok, :holdover}
    # candidate time 11, not trigger 20
    assert Follower.state(f, 22) == {:ok, :holdover}
    assert {:error, %Error{code: :order}} = Follower.observe(f, 19, 23)
    assert {:error, %Error{code: :order}} = Follower.observe(f, 21, 22)
  end

  test "first outlier reference not rolling comparison; equality; inlier clears run" do
    f = fresh(%{outlier_threshold_ns: 10, step_after: 3})
    f = read(f, 100, 80, :rejected, 20)
    # equality to first
    f = read(f, 120, 90, :rejected, 30)
    # rolling comparison would step incorrectly
    f = read(f, 140, 100, :rejected, 40)
    f = read(f, 160, 110, :rejected, 50)
    f = read(f, 170, 120, :stepped, 50)
    assert Follower.local(f, 120) == {:ok, 170}
    assert Follower.jitter(f) == 0
    f = read(f, 171, 121, :accepted, 0)
    f = read(f, 200, 130, :rejected, 20)
    f = read(f, 201, 151, :accepted, 0)
    f = read(f, 230, 160, :rejected, 20)
    assert {:error, %Error{code: :order}} = Follower.observe(f, 229, 161)
    assert Follower.state(f, 5_000_000_202) == {:ok, :holdover}
  end

  test "step keeps learned rate clears lock jitter and reset clears all histories" do
    f =
      fresh(%{
        bandwidth_hz: 1.0,
        damping: 1.0,
        outlier_threshold_ns: 2_000_000,
        lock_threshold_ns: 2_000_000,
        lock_count: 1,
        step_after: 1
      })

    f = read(f, 1_001_000_000, 1_000_000_000, :accepted, 1_000_000)

    assert {:ok, f, %{status: :accepted, error_ns: e}} =
             Follower.observe(f, 2_002_000_000, 2_000_000_000)

    assert e != 0
    assert Follower.jitter(f) > 0
    assert Follower.state(f, 2_002_000_000) == {:ok, :locked}
    y = Follower.offset(f)
    assert {:ok, f, %{status: :stepped}} = Follower.observe(f, 3_000_000_000, 4_000_000_000)
    assert Follower.offset(f) == y
    assert Follower.jitter(f) == 0
    assert Follower.state(f, 3_000_000_000) == {:ok, :acquiring}
    assert Follower.local(f, 4_000_000_000) == {:ok, 3_000_000_000}

    assert {:ok, f, %{status: :accepted, error_ns: e}} =
             Follower.observe(f, 3_000_000_000, 4_000_001_000)

    assert e != 0
    # first inlier after step, not third overall
    assert Follower.jitter(f) == 0
    f = Follower.reset(f)
    assert Follower.offset(f) == 0.0
    assert {:ok, _, %{status: :anchored}} = Follower.observe(f, -1, -1)

    # The same phase error after stepping starts a NEW outlier run.
    f = fresh(%{outlier_threshold_ns: 10, step_after: 3})
    f = read(f, 100, 80, :rejected, 20)
    f = read(f, 120, 100, :rejected, 20)
    f = read(f, 140, 120, :stepped, 20)
    _f = read(f, 170, 130, :rejected, 20)
  end

  test "signed-boundary elapsed windows and holdover use exact integer subtraction" do
    f = fresh(%{window_ns: @hi, holdover_after_ns: @hi}, @lo, @lo)
    f = read(f, @lo + 1, @lo + 1, :pending, 0)
    # elapsed hi-1
    f = read(f, -1, -1, :pending, 0)
    # elapsed hi
    f = read(f, 0, 0, :accepted, 0)
    assert Follower.state(f, 0) == {:ok, :acquiring}
    assert Follower.state(f, 1) == {:ok, :holdover}
  end

  test "window overflow rolls back candidate and order and permits a valid flush" do
    anchor = @hi - 1_000_000_000

    {:ok, rate} = Rate.units_per_second(1, 1)

    config = %{
      FollowerConfig.default(rate)
      | window_ns: 999_999_999,
        bandwidth_hz: 1.0,
        damping: 1.0,
        outlier_threshold_ns: @hi
    }

    {:ok, f} = Follower.new(config)
    # At dt=1 ns gain is tiny: predicting remote=2 would overflow the anchor.
    f = read(f, anchor, 0, :anchored, 0)
    f = read(f, anchor + 1, 2, :pending, 0)
    assert {:error, %Error{code: :overflow}} = Follower.observe(f, @hi, 4)
    assert Follower.local(f, 0) == {:ok, anchor}
    # Failed trigger did not consume order or candidate. The later in-window
    # reading has a strictly smaller signed error and enough gain to fit.
    continued = read(f, @hi - 1, 3, :pending, 0)
    continued = read(continued, @hi, 4, :accepted, -2_000_000_001)
    assert Follower.local(continued, 3) == {:ok, @hi - 1}
    # The supplied snapshot still owns the original overflowing candidate.
    assert {:error, %Error{code: :overflow}} = Follower.observe(f, @hi, 4)
  end

  test "trigger candidate error uses post-flush mapping and reset discards open window" do
    f = fresh(%{window_ns: 10, bandwidth_hz: 1.0e308, damping: 1.0})
    f = read(f, 10, 5, :pending, 0)
    f = read(f, 20, 15, :accepted, 5)
    # Mapping moved +5 on flush: trigger's error is now 0, not old +5.
    f = read(f, 30, 25, :accepted, 0)
    f = read(Follower.reset(f), -10, -10, :anchored, 0)
    f = read(f, -9, -9, :pending, 0)
    f = read(f, 1, 1, :accepted, 0)
    assert Follower.local(f, -9) == {:ok, -9}
  end

  test "README outlier and window workflows" do
    {:ok, rate} = Rate.units_per_second(1000, 1)
    {:ok, f} = Follower.new(FollowerConfig.default(rate))
    f = read(f, 0, 0, :anchored, 0)
    f = read(f, 10_000_000, 2010, :rejected, -2_000_000_000)
    f = read(f, 20_000_000, 2020, :rejected, -2_000_000_000)
    f = read(f, 30_000_000, 2030, :stepped, -2_000_000_000)
    assert Follower.local(f, 2030) == {:ok, 30_000_000}
    f = fresh(%{window_ns: 4, holdover_after_ns: 1})
    f = read(f, 1, 1, :pending, 0)
    f = read(f, 4, 4, :pending, 0)
    f = read(f, 5, 5, :accepted, 0)
    assert Follower.state(f, 3) == {:ok, :holdover}
  end
end
