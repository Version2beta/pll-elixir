defmodule PLL.FollowerMappingTest do
  use ExUnit.Case, async: true
  alias PLL.{Follower, FollowerConfig, Rate, Error}
  @lo -9_223_372_036_854_775_808
  @hi 9_223_372_036_854_775_807
  defp fresh(n, d) do
    {:ok, r} = Rate.units_per_second(n, d)
    {:ok, f} = Follower.new(FollowerConfig.default(r))
    f
  end

  defp anchor(n, d, l, r) do
    {:ok, f, %{status: :anchored, error_ns: 0}} = Follower.observe(fresh(n, d), l, r)
    f
  end

  test "unanchored queries, getters, misuse and scalar precedence" do
    f = fresh(1000, 1)
    assert {:error, %Error{code: :not_anchored}} = Follower.local(f, 0)
    assert {:error, %Error{code: :not_anchored}} = Follower.remote(f, 0)
    assert Follower.offset(f) == 0.0
    assert Follower.trim(f) == 0
    assert Follower.jitter(f) == 0
    assert Follower.state(f, 0) == {:ok, :acquiring}

    for fun <- [&Follower.local/2, &Follower.remote/2, &Follower.state/2] do
      assert {:error, %Error{code: :overflow}} = fun.(f, @hi + 1)
      assert {:error, %Error{code: :invalid_argument}} = fun.(f, 0.0)
      assert_raise ArgumentError, fn -> fun.(nil, 0) end
    end

    assert {:error, %Error{code: :invalid_argument}} = Follower.observe(f, nil, @hi + 1)
    assert {:error, %Error{code: :overflow}} = Follower.observe(f, @hi + 1, nil)
  end

  test "signed half ties round displacement rather than huge absolute anchor" do
    for base <- [1, -1, 9_007_199_254_740_993, -9_007_199_254_740_993] do
      f = anchor(2_000_000_000, 1, base, 0)
      assert Follower.local(f, -1) == {:ok, base - 1}
      assert Follower.local(f, 1) == {:ok, base + 1}
      assert Follower.remote(f, base - 1) == {:ok, -2}
      assert Follower.remote(f, base + 1) == {:ok, 2}
    end

    f = anchor(500_000_000, 1, 0, 9_007_199_254_740_993)
    assert Follower.remote(f, -1) == {:ok, 9_007_199_254_740_992}
    assert Follower.remote(f, 1) == {:ok, 9_007_199_254_740_994}
  end

  test "exact integer oracle for binary-exact periods and signed boundary cancellation" do
    for {n, d, pn, pd} <- [
          {1_000_000_000, 1, 1, 1},
          {2_000_000_000, 1, 1, 2},
          {500_000_000, 1, 2, 1}
        ],
        base <- [@lo + 4096, @hi - 4096],
        dr <- [-1023, -1, 0, 1, 1023] do
      f = anchor(n, d, base, 17)
      q = div(abs(dr * pn) * 2 + pd, 2 * pd) * if dr < 0, do: -1, else: 1
      assert Follower.local(f, 17 + dr) == {:ok, base + q}
    end

    f = anchor(1_000_000_000, 1, @lo, 0)
    # Displacement is 2^63, outside signed range, but integer base cancels.
    assert Follower.local(f, @hi) == {:ok, 0}
    f = anchor(1_000_000_000, 1, 0, @lo)
    assert Follower.remote(f, @hi) == {:ok, 0}
    f = anchor(1_000_000_000, 1, @hi, 0)
    assert {:error, %Error{code: :overflow}} = Follower.local(f, 1)
    assert Follower.local(f, 0) == {:ok, @hi}
  end

  test "integer difference before float conversion at huge anchors" do
    for a <- [@lo + 1024, @hi - 1024] do
      f = anchor(1_000_000_000, 1, a, a)

      for delta <- [-13, 0, 13] do
        assert Follower.local(f, a + delta) == {:ok, a + delta}
        assert Follower.remote(f, a + delta) == {:ok, a + delta}
      end
    end
  end
end
