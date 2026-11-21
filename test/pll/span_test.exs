# complete; do not change
defmodule PLL.SpanTest do
  use ExUnit.Case, async: true
  alias PLL.{Pacer, Rate, Span}

  test "SpanTimeNominal fractional floor does not accumulate rounded periods" do
    {:ok, r} = Rate.units_per_second(30_000, 1001)
    {:ok, p} = Pacer.new(r)
    assert {:ok, _, s} = Pacer.claim(p, 4)
    assert Enum.map(0..3, &Span.time(s, &1)) == [0, 33_366_666, 66_733_333, 100_100_000]
  end

  test "SpanTime bounds and wrong kinds raise exact exception categories" do
    {:ok, r} = Rate.units_per_second(1, 1)
    {:ok, p} = Pacer.new(r)
    assert {:ok, _, s} = Pacer.claim(p, 2)

    for i <- [-1, 2, 18_446_744_073_709_551_616] do
      assert_raise Enum.OutOfBoundsError, fn -> Span.time(s, i) end
    end

    for i <- [nil, 0.0, "0"] do
      assert_raise ArgumentError, fn -> Span.time(s, i) end
    end

    for bad <- [nil, %{}, r] do
      assert_raise ArgumentError, fn -> Span.time(bad, 0) end
      assert_raise ArgumentError, fn -> Span.all(bad) end
    end

    assert Span.time(s, 1) == 1_000_000_000
  end

  test "zero and issued empty spans enumerate nothing and reject all indexes" do
    {:ok, r} = Rate.units_per_second(1, 1)
    {:ok, p} = Pacer.new(r)
    {:ok, p1, _} = Pacer.claim(p, 1)
    {:ok, _, empty} = Pacer.due(p1, 0, 1)

    for s <- [%Span{}, empty] do
      assert Enum.to_list(Span.all(s)) == []
      assert_raise Enum.OutOfBoundsError, fn -> Span.time(s, 0) end
      assert_raise Enum.OutOfBoundsError, fn -> Span.time(s, -1) end
      assert_raise ArgumentError, fn -> Span.time(s, nil) end
    end
  end

  @tag timeout: 5000
  test "SpanAll is reusable lazy Enumerable and halts on enormous issued span" do
    u = 18_446_744_073_709_551_615
    {:ok, r} = Rate.units_per_second(u, 1)
    {:ok, p} = Pacer.new(r)
    assert {:ok, _, s} = Pacer.claim(p, u)
    enumerable = Span.all(s)
    refute is_list(enumerable)
    assert Enum.take(enumerable, 3) == [{0, 0}, {1, 0}, {2, 0}]
    assert Enum.take(enumerable, 1) == [{0, 0}]
    assert Enum.take(Span.all(s), 2) == [{0, 0}, {1, 0}]
    assert Enum.reduce_while(enumerable, [], fn item, _ -> {:halt, [item]} end) == [{0, 0}]
  end
end
