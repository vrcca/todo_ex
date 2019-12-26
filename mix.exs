defmodule TodoEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :todo_ex,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {TodoEx.Application, []}
    ]
  end

  defp deps do
    [
      {:mix_test_watch, "~> 0.8", only: :dev},
      {:ex_unit_notifier, "~> 0.1", only: :test},
      {:poolboy, "~> 1.5"},
      {:plug_cowboy, "~> 2.1"}
    ]
  end
end
