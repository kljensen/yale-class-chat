
defmodule App.Notifications do
  use GenServer
  alias App.Repo
  require Logger

  @moduledoc """
  # App.Notifications

  Listen to changes on the 'events' channel of our PostgreSQL
  database.
  """
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(opts \\ []),
    do: GenServer.start_link(__MODULE__, opts)


  @channel "events"
  @impl true
  def init(_opts) do
    {:ok, pid} = Postgrex.Notifications.start_link(App.Repo.config()) 
    ref = Postgrex.Notifications.listen!(pid, @channel)

    {:ok, {pid, ref, @channel}}
  end

  @impl true
  def handle_info({:notification, _pid, _ref, @channel, payload}, opts \\ []) do
    with {:ok, data} <- Poison.decode(payload, keys: :atoms) do
      data
      |> inspect()
      |> Logger.info()

      {:noreply, :event_handled}
    else
      error -> {:stop, error, []}
    end
  end
end
