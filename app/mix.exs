defmodule App.MixProject do
  use Mix.Project

  def project do
    [
      app: :app,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        ignore_warnings: ".dialyzer_ignore.exs"
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {App.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.14"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.1"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.14"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      # Use Dialyxir for static analysis
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev, :test], runtime: false},
      # Use mix-test.watch to run tests on code change
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      # Enforce code style and identify bad code
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
      # Static analaysis for Phoenix security
      {:sobelow, "~> 0.8", only: [:dev, :test]},
      # Using uberauth for CAS authentication
      {:ueberauth_cas, git: "https://github.com/kljensen/ueberauth_cas.git", tag: "v0.2"},
      {:ueberauth, "~> 0.6"},
      # Using Phoenix LiveView for front-end
      {:phoenix_live_view, "~> 0.8.0"},
      {:floki, ">= 0.0.0"},
      # Using tzdata for time zone conversions
      {:tzdata, "~> 1.0.1"},
      # Using EctoFields for URL and email validation
      {:ecto_fields, "~> 1.2.0"},
      # Use tesla and hackney for external REST API requests
      {:tesla, "~> 1.3.0"},
      {:hackney, "~> 1.15.2"},
      # Use poison for JSON parsing
      {:poison, "~> 3.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
