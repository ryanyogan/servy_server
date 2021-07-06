defmodule Servy.MixProject do
  use Mix.Project

  def project do
    [
      app: :servy,
      description: "Humble HTTP server",
      version: "0.1.1",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :eex],
      mod: {Servy, []},
      env: [port: 3000]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2"},
      {:earmark, "~> 1.4"},
      {:httpoison, "~> 1.8"}
    ]
  end
end
