defmodule ExCart.Mixfile do
  use Mix.Project

  @version "1.0.0"
  @source_url "https://github.com/data-twister/ExCart"

  def project do
    [
      app: :ex_cart,
      version: @version,
      elixir: "~> 1.13",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      description: description(),
      deps: deps(),
      dialyzer: dialyzer()
    ]
  end

  def application do
    [applications: [:logger, :nanoid], mod: {ExCart.Application, []}]
  end

  defp deps do
    [
      {:nanoid, "2.1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:earmark, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description do
    "E-commerce cart for Elixir."
  end

  defp package do
    # These are the default files included in the package
    [
      name: :ex_cart,
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Jason Clark"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/data-twister/ex_cart"}
    ]
  end

  defp dialyzer() do
    [
      plt_add_deps: :transitive,
      plt_add_apps: [:ex_unit, :mix],
      flags: [
        :error_handling,
        :race_conditions,
        :underspecs,
        :unmatched_returns
      ]
    ]
  end

  defp docs() do
    [
      extras: ["README.md"],
      main: "readme",
      homepage_url: @source_url,
      source_ref: "v#{@version}",
      source_url: @source_url,
    ]
  end
end
