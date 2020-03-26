defmodule AppWeb.TopicLive do
  use Phoenix.LiveView
  require Logger
  require Phoenix.PubSub
  require App.Notifications
  alias App.Topics.Topic


  def render(assigns) do
    ~L"""
    Current temperature: <%= @temperature %> <br>
    Topic title = **<%= @topic.title %>**<br>
    """
  end

  defp subscribe(model, id) do
    notification_topic = App.Notifications.topic_for_model(model)
    Phoenix.PubSub.subscribe(App.PubSub, notification_topic)
  end

  @doc """
  Mount is called twice, once on first render and then
  again after the websocket connection is made. You can
  check which run it is via the `connected?(socket)`
  function. `mount/3` takes three arguments.
  The first argument is the URL params. The second are
  the session variables, and the last is the socket.
  """
  def mount(%{"id" => id}, %{"uid" => uid}, socket) do
    if connected?(socket) do
      :ok = subscribe(Topic, id)
    end
    topic_data = App.Topics.get_topic_data_for_net_id(uid, id)
    temperature = 50
    socket = socket 
    |> assign(topic_data)
    |> assign(:id, id)
    |> assign(:temperature, temperature)

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
    Logger.info(">>>>woot")
    action
    |> inspect()
    |> Logger.info()
    Logger.info("<<<<woot")
    temperature = socket.assigns.temperature + 1
    {:noreply, assign(socket, :temperature, temperature)}
  end

end