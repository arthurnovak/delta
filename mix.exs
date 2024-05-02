defmodule Routes.MixProject do
  use Mix.Project

  def project do
    [
      app: :delta,
      version: "0.0.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jiffy, "~> 1.1"}
    ]
  end
end
