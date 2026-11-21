# Complete; do not change. Strict dependency-free public-Go corpus parser.
defmodule PLL.GoCorpus do
  @revision "971282632129110794c9d6edd22026e9de2359be"
  def load(path) do
    ["PLL-CORPUS 1 " <> @revision | lines] = File.read!(path) |> String.split("\n", trim: true)

    Enum.map(lines, fn line ->
      case String.split(line, " ") do
        ["C", name, rate, window, b, d, threshold] ->
          {:config, name, int(rate), int(window), float(b), float(d), int(threshold)}

        ["END"] ->
          :end

        [op, l, r, code, status, e, lc, lv, rc, rv, y, trim, jitter, state]
        when op in ["O", "Q", "R"] ->
          {:record, op, int(l), int(r), code, status, int(e), lc, int(lv), rc, int(rv), float(y),
           int(trim), int(jitter), state}
      end
    end)
  end

  defp int(s) do
    true = Regex.match?(~r/^-?(0|[1-9][0-9]*)$/, s)
    String.to_integer(s)
  end

  defp float(s) do
    true = Regex.match?(~r/^[0-9a-f]{16}$/, s)
    <<v::float-64>> = Base.decode16!(s, case: :lower)
    v
  end
end
