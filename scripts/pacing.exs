# complete; do not change
Code.require_file("pacing/contract.exs", __DIR__)
Code.require_file("pacing/runner.exs", __DIR__)
Code.require_file("pacing/runtime.exs", __DIR__)

case PLLPacing.Contract.parse(System.argv()) do
  {:error, _} ->
    IO.puts(:stderr, "pacing: invalid options")
    System.halt(2)

  {:ok, cfg} ->
    IO.inspect(
      %{
        schema: "pll-pacing-v1",
        options: cfg,
        elixir: System.version(),
        otp: System.otp_release(),
        architecture: to_string(:erlang.system_info(:system_architecture)),
        schedulers: :erlang.system_info(:schedulers_online),
        effective_per_datagram: if(cfg.udp == :discard, do: 1, else: cfg.per_datagram),
        receipt_measured: false
      },
      label: "target"
    )

    case PLLPacing.Runtime.execute(cfg) do
      %{stop: :deadline} = result ->
        IO.inspect(result, label: "result")

      result ->
        IO.inspect(result, label: "incomplete")
        System.halt(1)
    end
end
