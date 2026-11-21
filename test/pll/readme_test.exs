# complete; do not change
defmodule PLL.ReadmeTest do
  use ExUnit.Case, async: true
  alias PLL.{Pacer, Rate, Span}

  test "README first useful example executes every promised match" do
    {:ok, rate} = Rate.units_per_second(48_000, 1)
    {:ok, p0} = Pacer.new(rate)
    {:ok, p1, a} = Pacer.due(p0, 0, 4096)
    {:ok, p2, b} = Pacer.due(p1, 10_000_000, 4096)
    {:ok, p3, c} = Pacer.due(p2, 25_000_000, 4096)
    assert Enum.map([a, b, c], &{&1.first, &1.count}) == [{0, 1}, {1, 480}, {481, 720}]
    assert Pacer.next_due(p3) == {:ok, {1201, 25_020_834}}
    assert Pacer.due(p0, 0, 4096) == {:ok, p1, a}
  end

  test "README fractional and variable byte rate examples" do
    {:ok, rate} = Rate.units_per_second(60_000, 2002)

    assert {Rate.num(rate), Rate.den(rate), Rate.to_string(rate)} ==
             {30_000, 1001, "30000/1001 units/s"}

    {:ok, p0} = Pacer.new(rate)
    {:ok, _, span} = Pacer.claim(p0, 4)

    assert Enum.to_list(Span.all(span)) == [
             {0, 0},
             {1, 33_366_666},
             {2, 66_733_333},
             {3, 100_100_000}
           ]

    {:ok, byte_rate} = Rate.bits_per_second(50_000_000, 8)
    {:ok, bytes0} = Pacer.new(byte_rate)

    {starts, _} =
      Enum.map_reduce([1500, 400, 1500], bytes0, fn n, p ->
        {:ok, next, s} = Pacer.claim(p, n)
        {Span.time(s, 0), next}
      end)

    assert starts == [0, 240_000, 304_000]
  end
end
