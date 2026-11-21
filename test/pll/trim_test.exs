# complete; do not change
defmodule PLL.TrimTest do
  use ExUnit.Case, async: true
  alias PLL.{Error, Pacer, Rate, Span}
  @u 18_446_744_073_709_551_615
  @i 9_223_372_036_854_775_807
  defp pacer(n, d \\ 1) do
    {:ok, r} = Rate.units_per_second(n, d)
    {:ok, p} = Pacer.new(r)
    p
  end

  test "README skip and slow trim retain original span timing" do
    p0 = pacer(1000)
    {:ok, p1, 8} = Pacer.skip(p0, 10_000_000, 3)
    {:ok, p2, old} = Pacer.due(p1, 10_000_000, 3)
    assert Enum.to_list(Span.all(old)) == [{8, 8_000_000}, {9, 9_000_000}, {10, 10_000_000}]
    assert {:ok, p3} = Pacer.set_trim(p2, -500_000_000_000)
    {:ok, _, slow} = Pacer.claim(p3, 3)
    assert Enum.to_list(Span.all(slow)) == [{11, 11_000_000}, {12, 13_000_000}, {13, 15_000_000}]
    assert Span.time(old, 2) == 10_000_000
    assert Pacer.trim(p2) == 0
    assert Pacer.trim(p3) == -500_000_000_000
    assert Pacer.next_due(p2) == {:ok, {11, 11_000_000}}
  end

  test "SetTrim reanchors at floor but identical trim is true no-op" do
    {:ok, p, old} = Pacer.claim(pacer(375_000_000), 2)
    assert Pacer.next_due(p) == {:ok, {2, 6}}
    assert {:ok, ^p} = Pacer.set_trim(p, 0)
    assert Pacer.next_due(p) == {:ok, {2, 6}}
    assert {:ok, p1} = Pacer.set_trim(p, 1)
    assert Pacer.next_due(p1) == {:ok, {2, 5}}
    assert Span.time(old, 1) == 2
    assert {:ok, p2, _} = Pacer.claim(p1, 1)
    before = Pacer.next_due(p2)
    assert {:ok, ^p2} = Pacer.set_trim(p2, 1)
    assert Pacer.next_due(p2) == before
  end

  test "same trim succeeds beyond representable cursor anchor but change fails atomically" do
    {:ok, p, s} = Pacer.claim(pacer(1, @u), 1)
    assert {:ok, ^p} = Pacer.set_trim(p, 0)
    assert Pacer.set_trim(p, 1) == {:error, %Error{code: :overflow}}
    assert Pacer.trim(p) == 0
    assert Span.time(s, 0) == 0
    assert {:ok, ^p, empty} = Pacer.due(p, @i, 1)
    assert empty.count == 0
  end

  test "extreme trims and full width rates use unbounded products" do
    for {n, d} <- [{48_000, 1}, {@u, @u - 1}, {4_294_967_295, 4_294_967_291}, {@u, 1}],
        q <- [-999_999_999_999, 999_999_999_999] do
      assert {:ok, p} = Pacer.set_trim(pacer(n, d), q)
      pn = d * 1_000_000_000_000_000_000_000
      pd = n * (1_000_000_000_000 + q)

      if div(2 * pn, pd) > @i do
        assert Pacer.claim(p, 3) == {:error, %Error{code: :overflow}}
        assert Pacer.next_due(p) == {:ok, {0, 0}}
      else
        assert {:ok, p1, s} = Pacer.claim(p, 3)
        assert Enum.map(0..2, &Span.time(s, &1)) == Enum.map(0..2, &div(&1 * pn, pd))
        expected_next = div(3 * pn + pd - 1, pd)

        if expected_next > @i do
          assert Pacer.next_due(p1) == {:error, %Error{code: :overflow}}
        else
          assert Pacer.next_due(p1) == {:ok, {3, expected_next}}
        end
      end
    end
  end

  test "floor-fit ceiling-overflow permits trim re-anchor" do
    {:ok, p, _} = Pacer.claim(pacer(2_000_000_000, @u), 1)
    assert {:ok, p1} = Pacer.set_trim(p, 1)
    assert Pacer.next_due(p1) == {:ok, {1, @i}}
    assert {:ok, p2, s} = Pacer.due(p1, @i, 1)
    assert Span.time(s, 0) == @i
    assert Pacer.next_due(p2) == {:error, %Error{code: :overflow}}
  end

  test "retained spans and snapshots survive many later changes" do
    p = pacer(30_000, 1001)
    {:ok, p1, old} = Pacer.claim(p, 5)
    original = Enum.to_list(Span.all(old))

    Enum.reduce([1, -1, 50_000_000, -50_000_000, 0], p1, fn q, acc ->
      {:ok, changed} = Pacer.set_trim(acc, q)
      {:ok, next, s} = Pacer.claim(changed, 2)
      assert Span.time(s, 0) >= elem(List.last(original), 1)
      assert Enum.to_list(Span.all(old)) == original
      next
    end)

    assert Pacer.trim(p1) == 0
    assert Pacer.next_due(p) == {:ok, {0, 0}}
  end
end
