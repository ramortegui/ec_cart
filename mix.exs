defmodule Ec.Cart.Mixfile do
  use Mix.Project

  def project do
    [app: :ec_cart,
     version: "0.1.1",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     description: description(),
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, "~> 0.14", only: :dev}]
  end

  defp description do
    "E-commerce cart for Elixir."
  end
  
  defp package do
    [# These are the default files included in the package
     name: :ec_cart,
     files: ["lib", "mix.exs", "README*"],
     maintainers: ["Ruben Amortegui"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/ramortegui/ec_cart" }
    ]
  end
end
