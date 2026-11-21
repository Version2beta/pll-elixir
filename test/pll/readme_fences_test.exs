defmodule PLL.ReadmeFencesTest do
  use ExUnit.Case, async: true

  test "all three executable README public API fences" do
    text = File.read!(Path.expand("../../README.md", __DIR__))

    blocks =
      Regex.scan(~r/```elixir\n(.*?)```/s, text, capture: :all_but_first)
      |> List.flatten()
      |> Enum.filter(&String.starts_with?(&1, "alias PLL."))

    assert length(blocks) == 3
    for block <- blocks, do: Code.eval_string(block, [], file: "README.md")
    # Remaining table examples explicitly include unfinished Stage 3 semantics.
    {:ok, r} = PLL.Rate.units_per_second(1000, 1)
    {:ok, f} = PLL.Follower.new(PLL.FollowerConfig.default(r))
    {:ok, f, _} = PLL.Follower.observe(f, 0, 0)
    assert {:ok, _, %{status: :rejected}} = PLL.Follower.observe(f, 10_000_000, 2010)
  end
end
