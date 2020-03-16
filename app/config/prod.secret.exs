# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

config :app, App.Repo,
  username: System.get_env("POSTGRES_USER"),
  password: System.get_env("POSTGRES_PASSWORD"),
  database: System.get_env("POSTGRES_DB"),
  hostname: System.get_env("POSTGRES_HOST"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

domain = System.get_env("DOMAIN")
config :app, AppWeb.Endpoint,
  secret_key_base: secret_key_base,
  url: [host: domain, port: 443],
  cache_static_manifest: "priv/static/cache_manifest.json",
  force_ssl: [hsts: true],
  http: [
    port: 80,
    transport_options: [socket_opts: [:inet6]]
  ],
  https: [
    port: 443,
    cipher_suite: :strong,
    keyfile: "/etc/letsencrypt/live/#{domain}/privkey.pem",
    certfile: "/etc/letsencrypt/live/#{domain}/cert.pem",
    cacertfile: "/etc/letsencrypt/live/#{domain}/fullchain.pem",
    transport_options: [socket_opts: [:inet6]]
  ]


# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :app, AppWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
