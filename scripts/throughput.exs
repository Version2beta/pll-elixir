# complete; do not change
Code.require_file("bench/contract.exs", __DIR__)
Code.require_file("bench/runner.exs", __DIR__)

case PLLBench.Contract.parse(System.argv()) do
  {:ok, config} ->
    PLLBench.Runner.main(config)

  {:error, message} ->
    IO.puts(:stderr, message)
    System.halt(2)
end
