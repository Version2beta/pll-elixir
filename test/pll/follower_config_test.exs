defmodule PLL.FollowerConfigTest do
  use ExUnit.Case, async: true
  alias PLL.{Follower, FollowerConfig, Rate, Error, Status, State}

  defp cfg do
    {:ok, r} = Rate.units_per_second(1000, 1)
    FollowerConfig.default(r)
  end

  test "all defaults and zero sentinel" do
    c = cfg()

    assert Map.from_struct(c) == %{
             nominal: c.nominal,
             bandwidth_hz: 0.1,
             damping: :math.sqrt(2) / 2,
             max_offset_ppm: 500.0,
             window_ns: 0,
             outlier_threshold_ns: 5_000_000,
             step_after: 3,
             lock_threshold_ns: 100_000,
             lock_count: 8,
             holdover_after_ns: 5_000_000_000
           }

    assert {:ok, _} = Follower.new(c)
    assert {:error, %Error{code: :config, field: :nominal}} = Follower.new(%FollowerConfig{})
    assert FollowerConfig.default(:bad).nominal == :bad
  end

  test "ordered config validation, type reasons and integer envelopes" do
    for {k, bad, reason} <- [
          {:nominal, :bad, "must be a valid Rate"},
          {:bandwidth_hz, 0.0, "must be finite and > 0"},
          {:damping, 1, "must be finite and > 0"},
          {:max_offset_ppm, 1_000_000.0, "must be finite, > 0 and < 1000000"},
          {:window_ns, -1, "must be >= 0"},
          {:outlier_threshold_ns, 0, "must be > 0"},
          {:step_after, 0, "must be >= 1"},
          {:lock_threshold_ns, -1, "must be >= 0"},
          {:lock_count, 0, "must be >= 1"},
          {:holdover_after_ns, 0, "must be > 0"}
        ] do
      assert {:error, %Error{code: :config, field: ^k, reason: ^reason}} =
               Follower.new(Map.put(cfg(), k, bad))

      assert {:error, %Error{code: :config, field: ^k}} = Follower.new(Map.put(cfg(), k, nil))
    end

    for k <- [
          :window_ns,
          :outlier_threshold_ns,
          :step_after,
          :lock_threshold_ns,
          :lock_count,
          :holdover_after_ns
        ] do
      assert {:error, %Error{code: :overflow}} =
               Follower.new(Map.put(cfg(), k, 9_223_372_036_854_775_808))
    end

    for k <- [
          :window_ns,
          :outlier_threshold_ns,
          :step_after,
          :lock_threshold_ns,
          :lock_count,
          :holdover_after_ns
        ] do
      assert {:error, %Error{code: :overflow}} =
               Follower.new(Map.put(cfg(), k, -9_223_372_036_854_775_809))
    end

    assert {:error, %Error{field: :bandwidth_hz}} =
             Follower.new(%{cfg() | bandwidth_hz: 0.0, lock_count: 0})

    assert_raise ArgumentError, fn -> Follower.new(nil) end
  end

  test "finite gain extremes are valid configurations" do
    for v <- [5.0e-324, 1.7976931348623157e308] do
      assert {:ok, _} = Follower.new(%{cfg() | bandwidth_hz: v, damping: v})
    end
  end

  test "status/state bytes and stable follower errors" do
    for {a, i} <- Enum.with_index([:anchored, :accepted, :pending, :rejected, :stepped], 1),
        do: assert(Status.to_string(a) == Status.to_string(i))

    for {a, i} <- Enum.with_index([:acquiring, :locked, :holdover]),
        do: assert(State.to_string(a) == State.to_string(i))

    assert Status.to_string(0) == "Status(0)"
    assert State.to_string(9) == "State(9)"
    for v <- [-1, 256, nil], do: assert_raise(ArgumentError, fn -> Status.to_string(v) end)
    assert Error.message(%Error{code: :order}) == "pll: reading out of order"
    assert Error.message(%Error{code: :not_anchored}) == "pll: follower has no reading yet"

    assert Error.message(%Error{code: :config, field: :lock_count, reason: "must be >= 1"}) ==
             "pll: FollowerConfig.lock_count must be >= 1"
  end
end
