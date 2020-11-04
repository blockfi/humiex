defmodule Humiex.MixProject do
  use Mix.Project

  @version "0.1.1"

  def project do
    [
      app: :humiex,
      description: description(),
      version: @version,
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "Query or stream Humio (humio.com) events using it's rest search API"
  end

  defp package() do
    [
      name: "humiex",
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      maintainers: ["Eduardo Moraga"],
      links: %{"GitHub" => "https://github.com/blockfi/humiex"}
    ]
  end

  defp docs() do
    [
      main: "readme",
      name: "Humiex",
      source_ref: "v#{@version}",
      canonical: "https://hexdocs.pm/humiex",
      source_url: "https://github.com/blockfi/humiex",
      extras: [
        "README.md"
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:httpoison, "1.2.0"},
      {:hackney, "1.16.0"},
      {:jason, "1.2.2"},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
