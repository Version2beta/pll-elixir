# complete; do not change
defmodule PLL.RateTest do
  use ExUnit.Case, async: true
  alias PLL.{Error, Rate}
  @u 18_446_744_073_709_551_615

  test "UnitsPerSecond reduces full-width exact terms" do
    for {n, d, a, b} <- [
          {60_000, 2002, 30_000, 1001},
          {48_000, 1, 48_000, 1},
          {@u, @u, 1, 1},
          {@u, @u - 1, @u, @u - 1},
          {1, @u, 1, @u}
        ] do
      assert {:ok, r} = Rate.units_per_second(n, d)
      assert {Rate.num(r), Rate.den(r)} == {a, b}
    end
  end

  test "BitsPerSecond is the identical fraction" do
    assert {:ok, r} = Rate.bits_per_second(50_000_000, 8)
    assert {Rate.num(r), Rate.den(r), Rate.to_string(r)} == {6_250_000, 1, "6250000 units/s"}
    assert Rate.bits_per_second(@u, 3) == Rate.units_per_second(@u, 3)
  end

  test "RateString and String.Chars exact spelling" do
    for {n, d, text} <- [{48_000, 1, "48000 units/s"}, {60_000, 2002, "30000/1001 units/s"}] do
      assert {:ok, r} = Rate.units_per_second(n, d)
      assert Rate.to_string(r) == text
      assert "#{r}" == text
    end
  end

  test "zero sentinel is invalid and readable" do
    assert {Rate.num(%Rate{}), Rate.den(%Rate{}), Rate.to_string(%Rate{})} ==
             {0, 0, "invalid rate"}

    assert "#{%Rate{}}" == "invalid rate"

    for {n, d} <- [{0, 1}, {1, 0}, {0, 0}] do
      assert Rate.units_per_second(n, d) == {:error, %Error{code: :invalid_rate}}
      assert Rate.bits_per_second(n, d) == {:error, %Error{code: :invalid_rate}}
    end
  end

  test "wrong scalar types return tagged invalid_argument" do
    for bad <- [1.0, "1", nil, true, [], %{}],
        fun <- [&Rate.units_per_second/2, &Rate.bits_per_second/2] do
      assert fun.(bad, 1) == {:error, %Error{code: :invalid_argument}}
      assert fun.(1, bad) == {:error, %Error{code: :invalid_argument}}
    end
  end

  test "unsigned envelopes never wrap" do
    for bad <- [-1, @u + 1], fun <- [&Rate.units_per_second/2, &Rate.bits_per_second/2] do
      assert fun.(bad, 1) == {:error, %Error{code: :overflow}}
      assert fun.(1, bad) == {:error, %Error{code: :overflow}}
    end
  end

  test "wrong Rate kind raises ArgumentError" do
    for bad <- [nil, 1, %{}, %PLL.Span{}], fun <- [&Rate.num/1, &Rate.den/1, &Rate.to_string/1] do
      assert_raise ArgumentError, fn -> fun.(bad) end
    end
  end

  test "stage error values have stable messages" do
    for {code, text} <- [
          invalid_rate: "pll: invalid rate",
          invalid_argument: "pll: invalid argument",
          overflow: "pll: overflow"
        ] do
      assert Error.message(%Error{code: code}) == text
    end

    assert {:ok, r} = Rate.units_per_second(6, 4)
    assert {Rate.num(r), Rate.den(r)} == {3, 2}
  end

  test "all scalar envelopes are checked left-to-right before semantics" do
    for fun <- [&Rate.units_per_second/2, &Rate.bits_per_second/2] do
      assert fun.(0, @u + 1) == {:error, %Error{code: :overflow}}
      assert fun.(0, nil) == {:error, %Error{code: :invalid_argument}}
      assert fun.(nil, @u + 1) == {:error, %Error{code: :invalid_argument}}
      assert fun.(-1, nil) == {:error, %Error{code: :overflow}}
    end
  end
end
