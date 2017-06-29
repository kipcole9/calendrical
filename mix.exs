defmodule Calendrical.Mixfile do
  use Mix.Project

  @version "0.1.1"

  def project do
    [
      app: :calendrical,
      version: @version,
      elixir: "1.5.0-rc.0",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env),
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      aliases: aliases(),
      name: "Calendrical",
      source_url: "https://github.com/kipcole9/calendrical",
      docs: docs()
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.15", only: :dev},
      {:csv, "> 0.0.0", only: [:dev, :test], optional: true},
      {:excoveralls, "~> 0.6.3", only: :test}
    ]
  end
  defp description do
    "Calendrical calculations and additional calendars based upon the work of Dershowitz " <>
    "and Reingold in Calendrical Calculations"
  end

  defp package do
    [
      maintainers: ["Kip Cole"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/kipcole9/calendrical",
        "Changelog" => "https://github.com/kipcole9/calendrical/blob/v#{@version}/CHANGELOG.md"},
      files: [
        "lib", "config", "mix.exs", "README.md", "CHANGELOG.md", "LICENSE.md"
      ]
    ]
  end

  def aliases do
    []
  end

  def docs do
    [
      source_ref: "v#{@version}",
      extras: ["README.md", "CHANGELOG.md"],
      main: "readme"
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "mix", "test", "test/support"]
  defp elixirc_paths(:dev),  do: ["lib", "mix"]
  defp elixirc_paths(_),     do: ["lib"]
end
