# complete; do not change
defmodule PLL.ModelTest do
  use ExUnit.Case, async: true
  alias PLL.{Error, Pacer, Rate, Span}
  alias PLL.Test.RationalOracle, as: Oracle
  @u 18_446_744_073_709_551_615
  @i 9_223_372_036_854_775_807

  defp actual(p, {:claim, n}), do: Pacer.claim(p, n)
  defp actual(p, {:due, now, n}), do: Pacer.due(p, now, n)
  defp actual(p, {:skip, now, n}), do: Pacer.skip(p, now, n)
  defp actual(p, {:trim, q}), do: Pacer.set_trim(p, q)
  defp actual(p, :next), do: Pacer.next_due(p)

  defp compare(n, d, ops) do
    {:ok, r} = Rate.units_per_second(n, d)
    {:ok, p} = Pacer.new(r)

    Enum.reduce(Enum.with_index(ops), {p, Oracle.new(n, d), []}, fn {op, index}, {p, m, spans} ->
      expected = Oracle.step(m, op)
      got = actual(p, op)

      context =
        "rate=#{n}/#{d} op##{index}=#{inspect(op)} expected=#{inspect(expected)} got=#{inspect(got)}"

      {next_p, next_m, retained} =
        case expected do
          {:error, code} ->
            assert got == {:error, %Error{code: code}}, context
            {p, m, spans}

          {:span, m1, {first, count, timing}} ->
            assert {:ok, p1, s} = got, context
            assert {s.first, s.count} == {first, count}, context
            samples = if count == 0, do: [], else: Enum.uniq([0, div(count, 2), count - 1])

            for i <- samples,
                do: assert(Span.time(s, i) == Oracle.floor(timing, first + i), context)

            assert Enum.take(Span.all(s), min(3, count)) ==
                     if(count == 0,
                       do: [],
                       else:
                         for(
                           i <- 0..(min(3, count) - 1),
                           do: {first + i, Oracle.floor(timing, first + i)}
                         )
                     ),
                   context

            retained =
              Enum.take(
                [{s, for(i <- samples, do: {i, Oracle.floor(timing, first + i)})} | spans],
                8
              )

            {p1, m1, retained}

          {:skip, m1, skipped} ->
            assert {:ok, p1, ^skipped} = got, context
            {p1, m1, spans}

          {:trim, m1} ->
            assert {:ok, p1} = got, context
            {p1, m1, spans}

          {:ok, pair} ->
            assert got == {:ok, pair}, context
            {p, m, spans}
        end

      assert Pacer.next_due(next_p) == oracle_error(Oracle.next(next_m)), context
      assert Pacer.trim(next_p) == next_m.q, context

      assert Pacer.next_due(p) == oracle_error(Oracle.next(m)),
             "old snapshot changed: " <> context

      assert Pacer.trim(p) == m.q, context
      for {s, samples} <- retained, {i, t} <- samples, do: assert(Span.time(s, i) == t, context)
      {next_p, next_m, retained}
    end)
  end

  defp oracle_error({:error, c}), do: {:error, %Error{code: c}}
  defp oracle_error(ok), do: ok

  test "Boundaries compare whole operation results against independent rational search" do
    cases = [
      {@u, 1,
       [{:claim, @u}, {:due, 0, 1}, {:due, 1_000_000_000, 1}, {:skip, @i, 0}, {:claim, 1}, :next]},
      {1, @u, [{:claim, 1}, :next, {:trim, 0}, {:trim, 1}, {:claim, 1}, {:due, @i, 9}]},
      {2_000_000_000, @u, [{:claim, 1}, :next, {:due, @i, 1}, {:claim, 1}, {:trim, 1}]},
      {@u, @u - 1, [{:claim, 9_223_372_036}, :next, {:claim, 1}, {:due, @i, @u}, {:trim, -1}]},
      {30_000, 1001,
       [
         {:claim, 1},
         {:trim, 1},
         {:claim, 999},
         {:trim, -1},
         {:claim, 1_000_000},
         {:trim, 999_999_999_999},
         {:claim, 1000},
         {:trim, -999_999_999_999},
         {:claim, 3},
         :next
       ]},
      {4_294_967_295, 4_294_967_291,
       [
         {:trim, 50_000_000},
         {:claim, 1},
         :next,
         {:due, 10_000_000_000, 4},
         {:skip, 20_000_000_000, 2},
         {:claim, 3}
       ]}
    ]

    for {n, d, ops} <- cases, do: compare(n, d, ops)
  end

  test "Differential seeded operations include earlier now extreme trims and retained spans" do
    rates = [
      {48_000, 1},
      {30_000, 1001},
      {375_000_000, 1},
      {2_000_000_000, 1},
      {@u, 1},
      {1, @u},
      {@u, @u - 1},
      {9_223_372_036_854_775_808, 3}
    ]

    for {n, d} <- rates, seed <- 1..6 do
      {ops, _} =
        Enum.map_reduce(1..80, :rand.seed_s(:exsss, {seed, n, d}), fn _, rng ->
          {v, rng} = :rand.uniform_s(1_000_000, rng)
          counts = [0, 1, 3, 4096, @u, 1_099_511_627_776]
          times = [-1, 0, 2, 10_000_000, 5_000_000, @i]

          trims = [
            0,
            1,
            -1,
            50_000_000,
            -50_000_000,
            999_999_999_999,
            -999_999_999_999,
            1_000_000_000_000
          ]

          count = Enum.at(counts, rem(div(v, 7), length(counts)))
          now = Enum.at(times, rem(div(v, 11), length(times)))

          op =
            case rem(v, 5) do
              0 -> {:claim, count}
              1 -> {:due, now, count}
              2 -> {:skip, now, count}
              3 -> {:trim, Enum.at(trims, rem(div(v, 13), length(trims)))}
              4 -> :next
            end

          {op, rng}
        end)

      compare(n, d, ops)
    end
  end
end
