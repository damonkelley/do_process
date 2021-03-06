defmodule DoProcess.Mixfile do
  use Mix.Project

  def project do
    [app: :do_process,
     version: "0.1.0",
     elixir: "~> 1.5",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {DoProcess.Application, []}]
  end

  defp deps do
    []
  end

  defp aliases do
    [test: "test --no-start --trace"]
  end
end
