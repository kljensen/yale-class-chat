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

  def mount(_params, %{"uid" => uid}, socket) do
    if connected?(socket) do
      # :timer.send_interval(5000, self(), :update)
      :ok = Phoenix.PubSub.subscribe(App.PubSub, "foo")
    end
    Logger.info("....in mount")
    socket
    |> inspect()
    |> Logger.info()
    temperature = 50
    socket = socket 
    |> assign_new(:temperature, fn -> temperature end)
    |> assign_new(:topic, fn -> %Topic{title: "foo"} end )
    temporary_assigns = [topic: %Topic{}]
    # temporary_assigns = []
    Logger.info("....in mount DONE")
    {:ok, socket, temporary_assigns: temporary_assigns}
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