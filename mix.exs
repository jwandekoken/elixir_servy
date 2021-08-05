defmodule Servy.MixProject do
  use Mix.Project

  def project do
    [
      app: :servy,
      description: "A humble HTTP server",
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex],
      # This specifies the callback module to invoke when the application is started
      # The first arg is the module name, the second is a list of args
      mod: {Servy, []},
      env: [port: 3000, env: Mix.env()]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:distillery, "~> 2.0"},
      {:poison, "~> 5.0"},
      {:httpoison, "~> 1.8"}
    ]
  end
end
