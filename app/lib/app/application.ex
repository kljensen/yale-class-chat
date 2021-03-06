defmodule App.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      App.Repo,
      # Start the endpoint when the application starts
      AppWeb.Endpoint,
      # Starts a worker by calling: App.Worker.start_link(arg)
      # {App.Worker, arg},
      worker(App.Notifications, ["events"], id: :database_events),
      worker(App.LiveViewNotifications, [], id: :live_view_notifications)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: App.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
