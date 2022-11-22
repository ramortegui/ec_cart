defmodule ExCart.Mixfile do
  use Mix.Project

  @version "1.0.0"

  def project do
    [
      app: :ex_cart,
      version: @version,
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      description: description(),
      deps: deps()
    ]
  end

  def application do
    [applications: [:logger], mod: {ExCart.Application, []}]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.14", only: :dev},
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:inch_ex, ">= 0.0.0", only: :docs},
      {:nanoid, "~> 2.0"}
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
end
