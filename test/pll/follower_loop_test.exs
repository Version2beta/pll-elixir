Code.require_file("../support/follower_equation_oracle_helper.exs", __DIR__)

defmodule PLL.FollowerLoopTest do
  use ExUnit.Case, async: true
  alias PLL.{Follower, FollowerConfig, Rate, Error, Pacer, Span}
  alias PLL.FollowerEquationOracle, as: O
  @hi 9_223_372_036_854_775_807
  @lo -9_223_372_036_854_775_808
  defp fresh(opts) do
    {:ok, r} = Rate.units_per_second(1000, 1)
    c = Map.merge(FollowerConfig.default(r), opts)
    {:ok, f} = Follower.new(c)
    {f, c}
  end

  defp anchor(opts \\ %{}, l \\ 0, r \\ 0) do
    {f, c} = fresh(opts)
    {:ok, f, _} = Follower.observe(f, l, r)
    {f, c}
  end

  test "moderate independent equation chain, jitter and extrapolation" do
    {f, c} = anchor()

    Enum.reduce(1..240, {f, O.anchor(0, 0)}, fn k, {f, o} ->
      l = k * 10_000_000 + rem(k * 7919, 10001) - 5000
      {o, e} = O.update(o, l, k * 10, 1.0e6, c.bandwidth_hz, c.damping, 0.0005)
      {:ok, f, obs} = Follower.observe(f, l, k * 10)
      assert obs.status == :accepted
      assert abs(obs.error_ns - round(e)) <= 1
      assert abs(Follower.offset(f) - o.y) <= 1.0e-12
      assert {:ok, mapped} = Follower.local(f, k * 10 + 17)
      assert abs(mapped - O.local(o, k * 10 + 17, 1.0e6)) <= 1
      assert abs(Follower.jitter(f) - if(k < 2, do: 0, else: round(:math.sqrt(o.m)))) <= 2
      {f, o}
    end)
  end

  test "lock equality, dt zero, two sample jitter, holdover exact bounds and reset" do
    {f, _} = anchor(%{lock_count: 2, lock_threshold_ns: 1_000_000})
    {:ok, g, %{error_ns: -1_000_000}} = Follower.observe(f, 0, 1)
    assert Follower.offset(g) == 0.0
    assert Follower.local(g, 1) == {:ok, 1_000_000}
    assert Follower.jitter(g) == 0
    {:ok, h, _} = Follower.observe(g, 2_000_000, 2)
    assert Follower.jitter(h) == 968_246
    assert Follower.state(h, 5_002_000_000) == {:ok, :locked}
    assert Follower.state(h, 5_002_000_001) == {:ok, :holdover}
    assert Follower.state(h, -1) == {:ok, :locked}
    assert {:error, %Error{code: :order}} = Follower.observe(h, 2_000_000, 2)
    reset = Follower.reset(h)
    assert Follower.offset(reset) == 0.0
    assert Follower.jitter(reset) == 0
    assert {:ok, _, %{status: :anchored}} = Follower.observe(reset, -10, -10)
    {custom, _} = anchor(%{holdover_after_ns: 5})
    {:ok, retained, _} = Follower.observe(Follower.reset(custom), 0, 0)
    assert Follower.state(retained, 5) == {:ok, :acquiring}
    assert Follower.state(retained, 6) == {:ok, :holdover}
    {ext, _} = anchor(%{}, @lo, 0)
    assert Follower.state(ext, @hi) == {:ok, :holdover}
  end

  test "final window anchoring, scalar precedence and outlier threshold equality" do
    {w, _} = fresh(%{window_ns: 1})
    assert {:ok, _, %{status: :anchored}} = Follower.observe(w, 0, 0)
    assert {:error, %Error{code: :overflow}} = Follower.observe(w, @hi + 1, 0)
    assert {:error, %Error{code: :invalid_argument}} = Follower.observe(w, nil, @hi + 1)
    assert {:error, %Error{code: :not_anchored}} = Follower.local(w, 0)
    assert {:ok, _, %{status: :anchored}} = Follower.observe(Follower.reset(w), 0, 0)
    {f, _} = anchor(%{outlier_threshold_ns: 1_000_000})
    assert {:ok, rejected, %{status: :rejected}} = Follower.observe(f, 10_000_001, 9)
    assert Follower.local(rejected, 9) == {:ok, 9_000_000}
    assert {:error, %Error{code: :order}} = Follower.observe(rejected, 10_000_000, 10)

    assert {:ok, g, %{status: :accepted, error_ns: 1_000_000}} =
             Follower.observe(f, 10_000_000, 9)

    assert {:error, %Error{code: :order}} = Follower.observe(g, 9_000_000, 10)
    assert {:error, %Error{code: :order}} = Follower.observe(g, 20_000_000, 9)
    # Historical message compatibility only; final transitions never emit it.
    assert Error.message(%Error{code: :unsupported}) == "pll: unsupported in Stage 2"
  end

  test "all extreme finite gain combinations, cap and tiny product" do
    for b <- [5.0e-324, 1.7976931348623157e308], d <- [5.0e-324, 1.7976931348623157e308] do
      {f, _} = anchor(%{bandwidth_hz: b, damping: d})
      {:ok, g, %{status: :accepted}} = Follower.observe(f, 1_001_000_000, 1000)
      expected_y = if b > 1.0, do: -0.25 / 1.001 * 0.001, else: 0.0
      assert abs(Follower.offset(g) - expected_y) < 1.0e-15
      # Capped kp=1 only for both large, otherwise effectively zero here.
      expected = if b > 1.0 and d > 1.0, do: 1_001_000_000, else: 1_000_000_000
      assert Follower.local(g, 1000) == {:ok, expected}
    end

    {f, _} =
      anchor(%{bandwidth_hz: 1.7976931348623157e308, damping: 1.7976931348623157e308}, 0, 0)

    {:ok, _, %{status: :accepted}} = Follower.observe(f, 1, 1)
  end

  test "overflowing feed rolls back and allows a fitting continuation" do
    # Binary64 rounds hi-1024 displacement to 2^63: corrected anchor exceeds hi.
    {f, _} = anchor(%{bandwidth_hz: 1.0e-300, damping: 1.0e-300, outlier_threshold_ns: @hi})
    assert {:error, %Error{code: :overflow}} = Follower.observe(f, @hi, 9_223_372_036_855)
    assert Follower.local(f, 0) == {:ok, 0}
    assert Follower.offset(f) == 0.0
    assert {:ok, _, %{status: :accepted}} = Follower.observe(f, 1_000_000, 1)
  end

  test "offset clamp and pacer-compatible near maximum trim" do
    {f, _} =
      anchor(%{
        max_offset_ppm: 999_999.9999999999,
        bandwidth_hz: 1.7976931348623157e308,
        damping: 1.0,
        outlier_threshold_ns: @hi
      })

    {:ok, g, _} = Follower.observe(f, 1, 1)
    assert Follower.trim(g) == 999_999_999_999
    {:ok, r} = Rate.units_per_second(1000, 1)
    {:ok, p} = Pacer.new(r)
    assert {:ok, _} = Pacer.set_trim(p, Follower.trim(g))

    {f, c} =
      anchor(%{
        max_offset_ppm: 999_999.9999999999,
        bandwidth_hz: 1.7976931348623157e308,
        damping: 1.0,
        outlier_threshold_ns: @hi
      })

    negative =
      Enum.reduce(1..5, f, fn k, acc ->
        {:ok, next, %{status: :accepted}} = Follower.observe(acc, k * 1_000_000_000, k)
        next
      end)

    assert Follower.offset(negative) == -c.max_offset_ppm * 1.0e-6
    assert Follower.trim(negative) == -999_999_999_999
    assert {:ok, _} = Pacer.set_trim(p, Follower.trim(negative))
  end

  test "README follower to pacer trim example and failures" do
    {f, _} = anchor(%{bandwidth_hz: 1.0, damping: 1.0})
    {:ok, g, %{status: :accepted, error_ns: 1_000_000}} = Follower.observe(f, 1_001_000_000, 1000)
    assert Follower.local(g, 1000) == {:ok, 1_001_000_000}
    assert Follower.trim(g) == -249_750_250
    {:ok, r} = Rate.units_per_second(1000, 1)
    {:ok, p} = Pacer.new(r)
    {:ok, p, _} = Pacer.claim(p, 1000)
    {:ok, p} = Pacer.set_trim(p, Follower.trim(g))
    {:ok, p, s} = Pacer.claim(p, 2)
    assert Enum.to_list(Span.all(s)) == [{1000, 1_000_000_000}, {1001, 1_001_000_249}]
    before = {Follower.offset(g), Follower.local(g, 1000), Pacer.next_due(p), Pacer.trim(p)}
    assert {:error, %Error{code: :order}} = Follower.observe(g, 1_001_000_000, 1000)
    assert {:error, %Error{code: :invalid_argument}} = Pacer.set_trim(p, 1_000_000_000_000)

    assert before ==
             {Follower.offset(g), Follower.local(g, 1000), Pacer.next_due(p), Pacer.trim(p)}
  end

  test "default clean lock workflow, lock clearing and retained snapshots" do
    {f, _} = anchor()

    g =
      Enum.reduce(1..8, f, fn k, acc ->
        {:ok, next, %{status: :accepted, error_ns: 0}} =
          Follower.observe(acc, k * 10_000_000, k * 10)

        next
      end)

    assert Follower.state(g, 5_080_000_000) == {:ok, :locked}
    assert Follower.state(g, 5_080_000_001) == {:ok, :holdover}
    assert Follower.offset(g) == 0.0
    assert Follower.trim(g) == 0
    assert Follower.jitter(g) == 0
    {:ok, h, _} = Follower.observe(g, 91_000_000, 90)
    assert Follower.state(h, 91_000_000) == {:ok, :acquiring}
    assert Follower.state(f, 0) == {:ok, :acquiring}
    assert Follower.local(f, 0) == {:ok, 0}
  end

  test "unrounded outlier threshold and saturated observation and jitter" do
    {:ok, r} = Rate.units_per_second(2_000_000_000, 1)
    c = %{FollowerConfig.default(r) | outlier_threshold_ns: 1}
    {:ok, z} = Follower.new(c)
    {:ok, z, _} = Follower.observe(z, 0, 0)
    assert {:ok, _, %{error_ns: -1}} = Follower.observe(z, 0, 1)
    assert {:ok, _, %{status: :rejected, error_ns: -2}} = Follower.observe(z, 0, 3)
    # Exact 1.25ns distinguishes unrounded classification from round-away(-1.25)=-1.
    {:ok, r} = Rate.units_per_second(800_000_000, 1)
    c = %{FollowerConfig.default(r) | outlier_threshold_ns: 1}
    {:ok, z} = Follower.new(c)
    {:ok, z, _} = Follower.observe(z, 0, 0)
    assert {:ok, _, %{status: :rejected, error_ns: -1}} = Follower.observe(z, 0, 1)
    c = %{FollowerConfig.default(r) | lock_threshold_ns: 1, lock_count: 1}
    {:ok, z} = Follower.new(c)
    {:ok, z, _} = Follower.observe(z, 0, 0)
    {:ok, z, %{status: :accepted, error_ns: -1}} = Follower.observe(z, 0, 1)
    assert Follower.state(z, 0) == {:ok, :acquiring}
    {:ok, r} = Rate.units_per_second(1_000_000_000, 1)

    c = %{
      FollowerConfig.default(r)
      | outlier_threshold_ns: @hi,
        lock_threshold_ns: @hi,
        lock_count: 1
    }

    {:ok, z} = Follower.new(c)
    {:ok, z, _} = Follower.observe(z, 0, @lo)
    {:ok, z, %{error_ns: @lo}} = Follower.observe(z, 0, 0)
    {:ok, z, %{error_ns: @lo}} = Follower.observe(z, 0, 1)
    assert Follower.jitter(z) == @hi
    assert Follower.state(z, 0) == {:ok, :locked}
  end
end
