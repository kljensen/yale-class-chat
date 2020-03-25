defmodule AppWeb.TopicLive do
  use Phoenix.LiveView
  require Logger
  require Phoenix.PubSub
  alias App.Topics.Topic


  def render(assigns) do
    ~L"""
    Current temperature: <%= @temperature %> <br>
    Topic title: <%= @topic.title %>.<br>
    """
  end

  def mount(_params, %{"uid" => uid, "id" => id}, socket) do
    if connected?(socket) do
      # :timer.send_interval(5000, self(), :update)
      :ok = Phoenix.PubSub.subscribe(App.PubSub, "foo")
    end
    Logger.info("....in liveview mount for topic id #{id}")
    socket
    |> inspect()
    |> Logger.info()
    temperature = 50
    topic_data = App.Topics.get_topic_data_for_user(uid, id)
    socket = socket 
    |> assign(topic_data)
    |> assign_new(:temperature, fn -> temperature end)
    # temporary_assigns = []
    Logger.info("....in mount DONE")
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