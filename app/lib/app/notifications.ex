
defmodule App.Notifications do
  use GenServer
  alias App.Repo
  require Logger
  require Phoenix.PubSub
  @moduledoc """
  # App.Notifications

  Listen to changes on the 'events' channel of our PostgreSQL
  database.
  """

  # The pg_notify channel on which we listen
  @pg_channel "events"
  # Server to which we send broadcasts
  @pubsub_server App.PubSub
  # Prefix we append to all broadcasts
  @topic_key_prefix "repo_changes"

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(opts \\ []),
    do: GenServer.start_link(__MODULE__, opts)


  @impl true
  def init(_opts) do
    {:ok, pid} = Postgrex.Notifications.start_link(App.Repo.config()) 
    ref = Postgrex.Notifications.listen!(pid, @pg_channel)
    ref = Postgrex.Notifications.listen!(pid, "events:details")
    {:ok, {pid, ref, @pg_channel}}
  end


  @doc """
  Returns the Postgres table name for an Ecto model
  """
  def table_name_for_model(model) do
    model.__struct__.__meta__.source
  end

  @doc """
  Broadcasts on the pubsub_socket for this module.
  """
  defp broadcast!(key, message) do
      Phoenix.PubSub.broadcast!(@pubsub_server, key, message)
  end


  @doc """
  Key for when you want to track all changes. You'll
  get any change to any table that has a trigger sending
  `pg_notify` messages to the `@pg_channel`.
  """
  def key_for_all() do
    "#{@topic_key_prefix}"
  end

  @doc """
  Key for when you want to track changes to a table,
  e.g. "comments", or "topics"
  """
  def key_for_table(table) do
    "#{@topic_key_prefix}:#{table}"
  end

  @doc """
  Key for when you want to track changes a row of a table
  with a particular id, e.g. "comments" and 53.
  """
  def key_for_table_and_id(table, id) do
    "#{@topic_key_prefix}:#{table}:#{id}"
  end

  @doc """
  Key for when you want to track changes a row of a table
  with a particular fk, e.g. "comments" and "submission_id" = 53.
  """
  def key_for_table_and_fk(table, fk, id) do
    "#{@topic_key_prefix}:#{table}:#{fk}=#{id}"
  end

  @doc """
  Topic if you want to know when there is an "UPDATE", "INSERT",
  or "DELETE" operation on a table.
  """
  def key_for_table_and_change_type(table, change_type) do
    "#{@topic_key_prefix}:#{table}:#{change_type}"
  end

  @doc """
  Key for when you want to track changes to a model,
  e.g. "Comment", or "Topic"
  """
  def key_for_model(model) do
    model
    |> table_name_for_model()
    |> key_for_table()
  end

  @doc """
  Key for when you want to track changes a row of a model
  with a particular id, e.g. `Comment` and 53.
  """
  def key_for_model_and_id(model, id) do
    model
    |> table_name_for_model()
    |> key_for_table_and_id(id)
  end

  @doc """
  Key for when you want to track changes a row of a model
  with a particular fk, e.g. `Comment` and `Submission` with id 53.
  In that case, we'd like to know whenever an event occurs
  involving a `Comment` that has a foreign key to a `Submission`
  with `id=53`. We assume the foreign key is `submission_id`.
  """
  def key_for_model_and_fk(model, fk_model, id) do
    table = table_name_for_model(model)
    fk_table = table_name_for_model(fk_model)
    fk = "#{fk_table}_id"
    key_for_table_and_fk(table, fk, id)
  end

  @doc """
  Topic if you want to know when there is an "UPDATE", "INSERT",
  or "DELETE" operation on a model, e.g. `Comment`.
  """
  def key_for_model_and_change_type(model, change_type) do
    model
    |> table_name_for_model()
    |> key_for_table_and_change_type(change_type)
  end


  @doc """
  Produces a list of topic keys to which we'll broadcast. I do not
  believe that there is a concept of globbing in subscriptions as
  you might find in amqp. Therefore, we're broadcasting on a number
  of topics to which clients can subscribe. Likely I should just
  broadcast on that which I know I'll use, but I doubt there is
  any cost to this.
  """
  defp keys_for_pg_notification(%{table: table, type: type, data: %{id: id}}) do
    [
      key_for_all(),
      key_for_table(table),
      key_for_table_and_change_type(table, type),
      key_for_table_and_id(table, id)
    ]
  end

  @doc """
  Takes a decoded payload and broadcasts it to the appropriate topic.
  """
  defp broadcast_change(pg_change_payload) do
    Logger.info("Broadcasting change..")
    do_broadcast = fn key -> broadcast!(key, pg_change_payload) end
    pg_change_payload
    |> keys_for_pg_notification()
    |> Enum.map(do_broadcast)
  end

  @impl true
  def handle_info({:notification, _pid, _ref, @pg_channel, notification_payload}, _opts \\ []) do
    with {:ok, pg_notification} <- Poison.decode(notification_payload, keys: :atoms) do
      pg_notification
      |> inspect()
      |> Logger.info()
      broadcast_change(pg_notification)
      {:noreply, :event_handled}
    else
      error -> {:stop, error, []}
    end
  end

  @impl true
  def handle_info({:notification, _pid, _ref, "events:details", notification_payload}, _opts) do
    Logger.info("got notification for events:details")
    notification_payload
    |> inspect()
    |> Logger.info()

    with {:ok, pg_notification} <- Poison.decode(notification_payload, keys: :atoms) do
      pg_notification
      |> inspect()
      |> Logger.info()
      {:noreply, :event_handled}
    else
      error -> {:stop, error, []}
    end
  end
end
