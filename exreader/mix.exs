defmodule Exreader.MixProject do
  use Mix.Project

  def project do
    [
      app: :exreader,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :xmerl]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
     {:credo, "~> 0.9.0-rc1", only: [:dev, :test], runtime: false},
     {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
     {:httpotion, "~> 3.1.0"}
    ]
  end
end
