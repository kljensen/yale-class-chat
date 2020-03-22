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
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: AppWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: App.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt:  System.get_env("SIGNING_SALT")
  ]

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

# Use UTC for timestamps
config :app, App.Repo, migration_timestamps: [type: :utc_datetime_usec]

# Load tzdata time zone library
config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Course Registration API credentials
config :app, RegistrationAPI,
    url: System.get_env("REGISTRATION_API_URL"),
    username: System.get_env("REGISTRATION_API_USERNAME"),
    password: System.get_env("REGISTRATION_API_PASSWORD")


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

