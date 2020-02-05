# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :app,
  ecto_repos: [App.Repo]

# Configures the endpoint
config :app, AppWeb.Endpoint,
  url: [host: "0.0.0.0"],
  secret_key_base: "mhsbG/cyuym5OCkDzoFKsmBgVCKr2ViT98bg0qzKSRTnMtlsdm8Pe2D3yke2zd29",
  render_errors: [view: AppWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: App.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  providers: [cas: {Ueberauth.Strategy.CAS, [
    service_validate_base_url: System.get_env("CAS_SERVICE_VALIDATE_BASE_URL"),
    base_url: System.get_env("CAS_BASE_URL"),
    callback: System.get_env("CAS_CALLBACK_URL"),
  ]}]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
