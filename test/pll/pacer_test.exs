# complete; do not change
defmodule PLL.PacerTest do
  use ExUnit.Case, async: true
  alias PLL.{Error, Pacer, Rate, Span}
  @u 18_446_744_073_709_551_615
  @i 9_223_372_036_854_775_807
  defp pacer(n \\ 1000, d \\ 1) do
    {:ok, r} = Rate.units_per_second(n, d)
    {:ok, p} = Pacer.new(r)
    p
  end

  defp error(code), do: {:error, %Error{code: code}}

  test "NewPacer starts cursor and trim at zero and rejects zero Rate" do
    assert Pacer.new(%Rate{}) == error(:invalid_rate)
    p = pacer()
    assert Pacer.trim(p) == 0
    assert Pacer.next_due(p) == {:ok, {0, 0}}
  end

  test "Claim issues ordered extent independent of now" do
    p = pacer()
    assert {:ok, p1, s} = Pacer.claim(p, 3)
    assert {s.first, s.count} == {0, 3}
    assert Enum.to_list(Span.all(s)) == [{0, 0}, {1, 1_000_000}, {2, 2_000_000}]
    assert Pacer.next_due(p1) == {:ok, {3, 3_000_000}}
    assert Pacer.next_due(p) == {:ok, {0, 0}}
    assert {:ok, ^p1, empty} = Pacer.due(p1, 0, 1)
    assert {empty.first, empty.count} == {3, 0}
  end

  test "Due uses exact time not the floor and NextDue uses ceiling" do
    p = pacer(375_000_000)
    assert {:ok, p1, s} = Pacer.claim(p, 1)
    assert Span.time(s, 0) == 0
    assert Pacer.next_due(p1) == {:ok, {1, 3}}
    assert {:ok, ^p1, empty} = Pacer.due(p1, 2, 5)
    assert empty.count == 0
    assert {:ok, p2, s1} = Pacer.due(p1, 3, 5)
    assert {s1.first, s1.count, Span.time(s1, 0)} == {1, 1, 2}
    assert Pacer.next_due(p2) == {:ok, {2, 6}}
  end

  test "Due caps backlog and earlier times can still drain it" do
    p = pacer()
    assert {:ok, p1, s1} = Pacer.due(p, 10_000_000, 3)
    assert {s1.first, s1.count} == {0, 3}
    assert {:ok, p2, s2} = Pacer.due(p1, 5_000_000, 9)
    assert {s2.first, s2.count} == {3, 3}
    assert {:ok, ^p2, empty} = Pacer.due(p2, 4_000_000, 9)
    assert {empty.first, empty.count} == {6, 0}
  end

  test "Skip retains newest keep and keep zero skips everything available" do
    p = pacer()
    assert {:ok, p1, 8} = Pacer.skip(p, 10_000_000, 3)
    assert {:ok, p2, s} = Pacer.due(p1, 10_000_000, 3)
    assert Enum.to_list(Span.all(s)) == [{8, 8_000_000}, {9, 9_000_000}, {10, 10_000_000}]
    assert {:ok, ^p2, 0} = Pacer.skip(p2, 0, @u)
    assert {:ok, ^p, 0} = Pacer.skip(p, 10_000_000, @u)
    assert {:ok, p3, 11} = Pacer.skip(p, 10_000_000, 0)
    assert Pacer.next_due(p3) == {:ok, {11, 11_000_000}}
  end

  test "above billion rate shares ns without decreasing times" do
    assert {:ok, p, s} = Pacer.due(pacer(2_000_000_000), 1, 20)
    assert Enum.to_list(Span.all(s)) == [{0, 0}, {1, 0}, {2, 1}]
    assert Pacer.next_due(p) == {:ok, {3, 2}}
  end

  test "PacerFloorFitsButCeilingOverflows README boundary" do
    assert {:ok, p, _} = Pacer.claim(pacer(2_000_000_000, @u), 1)
    assert Pacer.next_due(p) == error(:overflow)
    assert {:ok, ^p, s} = Pacer.due(p, @i, 1)
    assert {s.first, s.count} == {1, 0}
    assert {:ok, p1, s1} = Pacer.claim(p, 1)
    assert Span.time(s1, 0) == @i
    assert Pacer.claim(p1, 1) == error(:overflow)
  end

  test "cursor U is legal but never issued or skipped" do
    assert {:ok, p, s} = Pacer.claim(pacer(@u), @u)
    assert {s.first, s.count} == {0, @u}
    assert Span.time(s, @u - 1) == 999_999_999
    assert Pacer.next_due(p) == error(:overflow)
    assert Pacer.claim(p, 1) == error(:overflow)
    assert {:ok, ^p, empty} = Pacer.due(p, 0, 1)
    assert {empty.first, empty.count} == {@u, 0}
    assert Pacer.due(p, 1_000_000_000, 1) == error(:overflow)
    assert Pacer.skip(p, 1_000_000_000, @u) == error(:overflow)
    assert Pacer.skip(p, 1_000_000_000, 0) == error(:overflow)
    assert {:ok, ^p, 0} = Pacer.skip(p, 0, 0)
  end

  test "Due and Skip cap largest due slot at U then exclude U" do
    p = pacer(@u)
    assert {:ok, p1, s} = Pacer.due(p, @i, @u)
    assert s.count == @u
    assert Pacer.next_due(p1) == error(:overflow)
    assert {:ok, p2, n} = Pacer.skip(p, @i, 0)
    assert n == @u
    assert Pacer.next_due(p2) == error(:overflow)
  end

  test "claim overflow leaves usable original state and old spans" do
    p = pacer(1, @u)
    assert Pacer.claim(p, 2) == error(:overflow)
    assert Pacer.next_due(p) == {:ok, {0, 0}}
    assert {:ok, p1, s} = Pacer.claim(p, 1)
    assert Span.time(s, 0) == 0
    assert Pacer.claim(p1, 1) == error(:overflow)
    assert {:ok, ^p1, empty} = Pacer.due(p1, @i, @u)
    assert empty.count == 0
  end

  test "wrong scalar types are invalid_argument" do
    p = pacer()

    for bad <- [nil, 1.0, "1", true, %{}] do
      for call <- [
            fn -> Pacer.due(p, bad, 1) end,
            fn -> Pacer.due(p, 0, bad) end,
            fn -> Pacer.claim(p, bad) end,
            fn -> Pacer.skip(p, bad, 0) end,
            fn -> Pacer.skip(p, 0, bad) end,
            fn -> Pacer.set_trim(p, bad) end
          ] do
        assert call.() == error(:invalid_argument)
      end
    end
  end

  test "envelopes take overflow without wrapping" do
    p = pacer()

    for bad <- [-@i - 2, @i + 1] do
      assert Pacer.due(p, bad, 1) == error(:overflow)
      assert Pacer.skip(p, bad, 0) == error(:overflow)
      assert Pacer.set_trim(p, bad) == error(:overflow)
    end

    for bad <- [-1, @u + 1] do
      assert Pacer.claim(p, bad) == error(:overflow)
      assert Pacer.due(p, 0, bad) == error(:overflow)
      assert Pacer.skip(p, 0, bad) == error(:overflow)
    end
  end

  test "within-envelope invalid semantics and failure preservation" do
    p = pacer()

    for bad <- [-1, -@i - 1] do
      assert Pacer.due(p, bad, 1) == error(:invalid_argument)
      assert Pacer.skip(p, bad, 0) == error(:invalid_argument)
    end

    assert Pacer.due(p, 0, 0) == error(:invalid_argument)
    assert Pacer.claim(p, 0) == error(:invalid_argument)

    for bad <- [-@i - 1, @i, -1_000_000_000_000, 1_000_000_000_000] do
      assert Pacer.set_trim(p, bad) == error(:invalid_argument)
    end

    assert Pacer.next_due(p) == {:ok, {0, 0}}
    assert {:ok, _, s} = Pacer.claim(p, 1)
    assert Span.time(s, 0) == 0
  end

  test "wrong struct kinds raise ArgumentError before scalar checks" do
    for bad <- [nil, %{}, %Span{}] do
      assert_raise ArgumentError, fn -> Pacer.new(bad) end
    end

    for bad <- [nil, %{}, %Rate{}, %Span{}] do
      for call <- [
            fn -> Pacer.due(bad, nil, nil) end,
            fn -> Pacer.claim(bad, nil) end,
            fn -> Pacer.skip(bad, nil, nil) end,
            fn -> Pacer.next_due(bad) end,
            fn -> Pacer.set_trim(bad, nil) end,
            fn -> Pacer.trim(bad) end
          ] do
        assert_raise ArgumentError, call
      end
    end
  end

  test "all scalar envelopes precede semantics in signature order" do
    p = pacer()
    assert Pacer.due(p, -1, @u + 1) == error(:overflow)
    assert Pacer.due(p, -1, nil) == error(:invalid_argument)
    assert Pacer.skip(p, -1, @u + 1) == error(:overflow)
    assert Pacer.skip(p, -1, nil) == error(:invalid_argument)

    for fun <- [&Pacer.due/3, &Pacer.skip/3] do
      assert fun.(p, nil, @u + 1) == error(:invalid_argument)
      assert fun.(p, @i + 1, nil) == error(:overflow)
      assert fun.(p, @i + 1, 0) == error(:overflow)
    end
  end
end
