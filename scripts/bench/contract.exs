# complete; do not change
defmodule PLLBench.Contract do
  @moduledoc "Tool-only options and report arithmetic. No environment configuration."
  @type config :: %{iterations: pos_integer(), samples: pos_integer(), warmup: pos_integer()}
  @spec parse([String.t()]) :: {:ok, config()} | {:error, String.t()}
  def parse(args) do
    defaults = %{iterations: 1000, samples: 3, warmup: 100}

    case args do
      ["--smoke"] -> {:ok, %{iterations: 12, samples: 2, warmup: 4}}
      _ -> parse_pairs(args, defaults, MapSet.new())
    end
  end

  defp parse_pairs([], cfg, _), do: {:ok, cfg}

  defp parse_pairs([flag, value | rest], cfg, seen) do
    key = %{"--iterations" => :iterations, "--samples" => :samples, "--warmup" => :warmup}[flag]
    max = if key == :samples, do: 10, else: 10_000

    with true <- key != nil and not MapSet.member?(seen, key),
         true <- Regex.match?(~r/^[1-9][0-9]{0,4}$/, value),
         {n, ""} <- Integer.parse(value),
         true <- n <= max do
      parse_pairs(rest, Map.put(cfg, key, n), MapSet.put(seen, key))
    else
      _ -> {:error, "invalid or duplicate option: #{flag}"}
    end
  end

  defp parse_pairs(_, _, _), do: {:error, "expected option/value pairs or --smoke alone"}

  @spec metrics(pos_integer(), pos_integer(), pos_integer()) :: map()
  def metrics(elapsed_ns, calls, units) when elapsed_ns > 0 and calls > 0 and units > 0 do
    %{
      ns_per_op: elapsed_ns / calls,
      ops_per_s: calls * 1.0e9 / elapsed_ns,
      units_per_s: units * 1.0e9 / elapsed_ns
    }
  end
end
