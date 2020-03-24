defmodule AppWeb.TopicLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    Current temperature: <%= @temperature %>
    """
  end

  def mount(_params, %{"uid" => uid}, socket) do
    if connected?(socket), do: :timer.send_interval(5000, self(), :update)
    temperature = 50
    {:ok, assign(socket, :temperature, temperature)}
  end

  def handle_info(:update, socket) do
    temperature = socket.assigns.temperature + 1
    {:noreply, assign(socket, :temperature, temperature)}
  end
end