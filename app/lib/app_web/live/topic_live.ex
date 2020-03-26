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
    notification_topic = App.Notifications.topic_for_model(model)
    Phoenix.PubSub.subscribe(App.PubSub, notification_topic)
  end


  @doc """
  Load topic data into the assigns. Gets net_id and topic id
  from the socket assigns.
  """
  defp load_topic_data(%{"uid" => net_id, "id" => id} = socket) do
    load_topic_data(socket, net_id, id)
  end

  @doc """
  Load topic data into the assigns for this net_id and topic id.
  """
  defp load_topic_data(socket, net_id, id) do
    topic_data = App.Topics.get_topic_data_for_net_id(net_id, id)
    assign(socket, topic_data)
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
    if connected?(socket) do
      :ok = subscribe(Topic, id)
    end
    temperature = 50
    socket = socket 
    |> assign(:id, id)
    |> assign(:temperature, temperature)
    |> assign(:conn, AppWeb.Endpoint)
    |> load_topic_data(net_id, id)

    # Here, I fake the conn based on the suggestion in github:
    # https://github.com/phoenixframework/phoenix_live_view/issues/277
    # It seems to work but doesn't feel right. Mostly this is to get
    # `Routes.topic_submission_path(@conn, :new, @topic.id)` to work.
    # I think that's the only way in which I'm depending on the @conn.
    # TODO: refactor. One easy way is to pre-load all the routes we
    # need into assigns. Another, I should look at

    Logger.info("\n\n")
    socket.assigns
    |> inspect()
    |> Logger.info()
    Logger.info("....in mount DONE\n\n")

    Logger.info(socket.assigns.topic.title)

    {:ok, socket}
  end



  def handle_info(:update, socket) do
    temperature = socket.assigns.temperature + 1
    {:noreply, assign(socket, :temperature, temperature)}
  end
  def handle_info(action, socket) do
    Logger.info("\n\n\n>>>>Received a pg update for topic")
    action
    |> inspect()
    |> Logger.info()
    Logger.info("<<<<\n\n\n")
    temperature = socket.assigns.temperature + 1
    {:noreply, assign(socket, :temperature, temperature)}
  end

end