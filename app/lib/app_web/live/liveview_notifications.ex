
defmodule App.LiveViewNotifications do
  use GenServer
  alias App.Repo
  require Logger
  require Phoenix.PubSub
  require App.Notifications
  alias App.Topics.Topic

  @moduledoc """
  # App.Notifications

  A genserver that listens to our PubSub and 
  determines when various liveviews need to be updated,
  sending a boolean message to which they can subscribe.

  I didn't want the logic for this in App.Notifications
  nor in the individual liveviews (because the logic
  would then be running once for each client.)

  Make sure to supervise the process with something like
  worker(App.LiveViewNotifications, %{}, id: :live_view_notifications)
  in the app config.
  """

  # Server to which we send broadcasts
  @pubsub_server App.PubSub
  @prefix "updated"

  # def child_spec(opts) do
  #   %{
  #     id: __MODULE__,
  #     start: {__MODULE__, :start_link, [opts]}
  #   }
  # end

  def start_link(opts \\ []),
    do: GenServer.start_link(__MODULE__, opts)

  @impl true
  def init(_opts) do
    App.Notifications.subscribe_to_details()
    {:ok, :ok}
  end

  defp get_pubsub_server() do
    App.Notifications.get_pubsub_server()
  end

  defp broadcast!(key) do
    server = get_pubsub_server()
    Phoenix.PubSub.broadcast!(server, key, :true)
  end

  def subscribe_for_topic(id) do
    server = get_pubsub_server()
    key = key_for_topic(id)
    Phoenix.PubSub.subscribe(server, key)  
  end

  def unsubscribe_for_topic(id) do
    server = get_pubsub_server()
    key = key_for_topic(id)
    Phoenix.PubSub.unsubscribe(server, key)  
  end

  def key_for_topic(id) do
    "#{@prefix}:topic:#{id}"
  end

  def mark_topic_updated!(id) do
    key_for_topic(id)
    |> broadcast!()
  end

  def handle_info(%{table: table} = payload, socket) do
    topic_id_path_keys = case table do
      "topics" -> [:data, :id]
      "submissions" -> [:data, :topic, :id]
      "comments" -> [:data, :submission, :topic, :id]
      "ratings" -> [:data, :submission, :topic, :id]
    end
    topic_id = get_in(payload, topic_id_path_keys)
    mark_topic_updated!(topic_id)
    Logger.info("\n\n\n>>>>Received a pg update for topic with id \"#{topic_id}\"")
    {:noreply, :event_handled}
  end

end
