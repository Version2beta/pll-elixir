defmodule PLL.MixProject do
  use Mix.Project

  def project do
    [
      app: :pll,
      version: "0.1.0",
      elixir: ">= 1.15.0",
      description: "Exact rational pacing and clock following",
      source_url: "https://github.com/Version2beta/pll-elixir",
      package: [
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/Version2beta/pll-elixir"},
        files: ["lib", "mix.exs", "README.md", "LICENSE", "CHANGELOG.md"]
      ],
      deps: []
    ]
  end

  def application, do: []
end
