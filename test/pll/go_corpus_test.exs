Code.require_file("../support/go_corpus_helper.exs", __DIR__)

defmodule PLL.GoCorpusTest do
  use ExUnit.Case, async: true
  alias PLL.{Follower, FollowerConfig, Rate, GoCorpus}

  test "pinned public Go corpus classifications and numerical results" do
    records = GoCorpus.load(Path.expand("../fixtures/go_public_v1.txt", __DIR__))
    assert length(records) == 171

    Enum.reduce(records, nil, fn
      {:config, name, rate, window, b, d, threshold}, _ ->
        {:ok, rate} = Rate.units_per_second(rate, 1)

        {:ok, f} =
          Follower.new(%{
            FollowerConfig.default(rate)
            | window_ns: window,
              bandwidth_hz: b,
              damping: d,
              outlier_threshold_ns: threshold
          })

        {f, name}

      :end, _ ->
        nil

      {:record, op, l, r, code, status, e, lc, lv, rc, rv, y, trim, jitter, state}, {f, name} ->
        f =
          case op do
            "Q" ->
              f

            "R" ->
              Follower.reset(f)

            "O" ->
              case Follower.observe(f, l, r) do
                {:ok, n, o} ->
                  assert code == "ok"
                  assert Atom.to_string(o.status) == status
                  assert abs(o.error_ns - e) <= tolerance(name)
                  n

                {:error, error} ->
                  assert Atom.to_string(error.code) == code
                  assert status == "none"
                  f
              end
          end

        check_query(Follower.local(f, r), lc, lv, tolerance(name))
        check_query(Follower.remote(f, l), rc, rv, tolerance(name))
        assert abs(Follower.offset(f) - y) <= if(name == "clean", do: 1.0e-12, else: 0.0)
        assert Follower.trim(f) == trim
        assert abs(Follower.jitter(f) - jitter) <= if(name == "clean", do: 2, else: 0)
        assert Follower.state(f, l) == {:ok, String.to_existing_atom(state)}
        {f, name}
    end)
  end

  defp tolerance("clean"), do: 1
  defp tolerance(_), do: 0

  defp check_query({:ok, v}, code, w, t),
    do:
      (
        assert code == "ok"
        assert abs(v - w) <= t
      )

  defp check_query({:error, e}, code, _w, _t), do: assert(Atom.to_string(e.code) == code)
end
