defmodule DoProcess.Umbrella.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  defp deps do
    [{:credo, "~> 0.8", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 0.5", only: [:dev], runtime: false}]
  end
end
