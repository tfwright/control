defmodule Control.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :control,
      version: @version,
      elixir: "~> 1.15",
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
      {:credo, "~> 1.7"}
    ]
  end
end
