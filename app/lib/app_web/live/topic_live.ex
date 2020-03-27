defmodule AppWeb.TopicLive do
  use Phoenix.LiveView
  require Logger
  require Phoenix.PubSub
  require App.Notifications
  alias App.Topics.Topic


  def render(assigns) do
    Phoenix.View.render(AppWeb.TopicView, "live.html", assigns)
  end

  defp subscribe(model, id) do
    notification_topic = App.Notifications.topic_for_model_and_id(model, id)
    # TODO: changeme
    # notification_topic = App.Notifications.topic_for_all()
    {Phoenix.PubSub.subscribe(App.PubSub, notification_topic), notification_topic}
  end


  @doc """
  Load topic data into the assigns. Gets net_id and topic id
  from the socket assigns.
  """
  defp load_topic_data(socket) do
    load_topic_data(socket, socket.assigns.uid, socket.assigns.id)
  end


  @doc """
  Load topic data into the assigns for this net_id and topic id.
  """
  defp load_topic_data(socket, net_id, id) do
    topic_data = App.Topics.get_topic_data_for_net_id(net_id, id)
    assign(socket, topic_data)
  end

  @doc """
  Adds subscriptions and removes stale subscriptions, returning
  the socket
  """
  defp setup_subscriptions(socket) do
  end

  @doc """
  Mount is called twice, once on first render and then
  again after the websocket connection is made. You can
  check which run it is via the `connected?(socket)`
  function. `mount/3` takes three arguments.
  The first argument is the URL params. The second are
  the session variables, and the last is the socket.
  """
  def mount(%{"id" => id}, %{"uid" => net_id}, socket) do
    Logger.info("....in mount BEGIN\n\n")
    if connected?(socket) do
      {:ok, topic_name} = subscribe(Topic, id)
    end

    socket = socket 
    |> assign(:id, id)
    |> assign(:conn, AppWeb.Endpoint)
    |> load_topic_data(net_id, id)

    # Here, I fake the conn based on the suggestion in github:
    # https://github.com/phoenixframework/phoenix_live_view/issues/277
    # It seems to work but doesn't feel right. Mostly this is to get
    # `Routes.topic_submission_path(@conn, :new, @topic.id)` to work.
    # I think that's the only way in which I'm depending on the @conn.
    # TODO: refactor. One easy way is to pre-load all the routes we
    # need into assigns. Another, I should look at

    {:ok, socket}
  end

  def handle_info(action, socket) do
    Logger.info("\n\n\n>>>>Received a pg update for topic")
    action
    |> inspect()
    |> Logger.info()
    Logger.info("socket.assigns is")
    socket.assigns
    |> inspect()
    |> Logger.info()
    Logger.info("<<<<\n\n\n")
    {:noreply, assign(socket, :topic, action.data)}
  end

end