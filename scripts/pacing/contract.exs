# complete; do not change
defmodule PLLPacing.Contract do
  @moduledoc "Bounded tool options and Go-compatible report arithmetic."
  @defaults %{bps: 19_392_658, unit_bytes: 188, seconds: 5, udp: :discard, per_datagram: 1}
  def parse(args), do: pairs(args, @defaults, MapSet.new())
  defp pairs([], cfg, _), do: validate(cfg)

  defp pairs([flag, value | rest], cfg, seen) do
    key =
      %{
        "--bps" => :bps,
        "--unit-bytes" => :unit_bytes,
        "--seconds" => :seconds,
        "--udp" => :udp,
        "--per-datagram" => :per_datagram
      }[flag]

    parsed =
      cond do
        key == :udp and value == "loopback" ->
          :loopback

        key != nil and key != :udp and is_binary(value) and byte_size(value) <= 9 and
            Regex.match?(~r/^[1-9][0-9]*$/, value) ->
          String.to_integer(value)

        true ->
          nil
      end

    if key && parsed && not MapSet.member?(seen, key),
      do: pairs(rest, Map.put(cfg, key, parsed), MapSet.put(seen, key)),
      else: {:error, :options}
  end

  defp pairs(_, _, _), do: {:error, :options}

  def validate(cfg) do
    if is_map(cfg) and Enum.sort(Map.keys(cfg)) == Enum.sort(Map.keys(@defaults)) and
         Enum.all?(
           [:bps, :unit_bytes, :seconds, :per_datagram],
           &(is_integer(cfg[&1]) and cfg[&1] > 0)
         ) and
         cfg.bps <= 100_000_000 and cfg.unit_bytes <= 65507 and cfg.seconds <= 10 and
         cfg.per_datagram <= 65507 and cfg.per_datagram * cfg.unit_bytes <= 65507 and
         cfg.udp in [:discard, :loopback] and
         1 + div(cfg.bps * cfg.seconds + 8 * cfg.unit_bytes - 1, 8 * cfg.unit_bytes) <= 1_000_000,
       do: {:ok, cfg},
       else: {:error, :options}
  end

  def quantile([], _), do: 0
  def quantile(sorted, f), do: Enum.at(sorted, floor(f * (length(sorted) - 1)))

  def report(r, cfg, elapsed, next_due) do
    sorted = Enum.sort(r.lateness)
    behind = max(0, elapsed - next_due)
    mbps = if elapsed > 0, do: r.accepted_bytes * 8000 / elapsed, else: 0.0
    timing = r.offered > 0 and behind <= 5_000_000 and quantile(sorted, 0.99) <= 5_000_000

    Map.merge(Map.delete(r, :lateness), %{
      elapsed_ns: elapsed,
      backlog_ns: behind,
      writer_mbps: mbps,
      lateness_samples: length(sorted),
      median_ns: quantile(sorted, 0.5),
      p99_ns: quantile(sorted, 0.99),
      max_ns: quantile(sorted, 1),
      average_batch: r.offered / max(1, r.due_calls),
      sustained: r.stop == :deadline and timing,
      demonstration_pass:
        r.stop == :deadline and timing and r.accepted_bytes == r.offered * cfg.unit_bytes and
          abs(mbps * 1_000_000 / cfg.bps - 1) <= 0.01
    })
  end
end
