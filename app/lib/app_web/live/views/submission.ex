defmodule AppWeb.SubmissionLive do
  use Phoenix.LiveView
  require Logger
  require Phoenix.PubSub
  require App.LiveViewNotifications
  alias App.Submissions.Submission
  require App.Submissions

  def render(assigns) do
    Phoenix.View.render(AppWeb.SubmissionView, "live.html", assigns)
  end

  @doc """
  Load submission data into the assigns. Gets net_id and submission id
  from the socket assigns.
  """
  defp load_submission_data(socket) do
    load_submission_data(socket, socket.assigns.net_id, socket.assigns.id)
  end


  @doc """
  Load submission data into the assigns for this net_id and submission id.
  """
  defp load_submission_data(socket, net_id, id) do
    {status, submission_data} = App.Submissions.get_submission_data_for_net_id!(net_id, id)
    case status do
      :ok ->
        assign(socket, submission_data)
      :error ->
        raise Errors.NotFound
    end
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
      App.LiveViewNotifications.subscribe_for_submission(id)
    end

    socket = socket 
    |> assign(:id, id)
    |> assign(:net_id, net_id)
    |> assign(:conn, AppWeb.Endpoint)
    |> load_submission_data(net_id, id)

    {:ok, socket}
  end

  def handle_info(action, socket) do
    Logger.info("\n\n\n>>>>Updating liveview")
    action
    |> inspect()
    |> Logger.info()
    {:noreply, load_submission_data(socket)}
  end

  defp current_user(socket) do
    Repo.get_by!(User, net_id: socket.assigns.net_id)
  end

  defp current_user(socket) do
    Repo.get_by!(User, net_id: socket.assigns.net_id)
  end

  defp create_comment(comment_data, socket) do
    App.Submissions.create_comment(socket.assigns.net_id, socket.assigns.id, comment_data)
  end

  defp create_rating!(comment_data, socket) do
    App.Submissions.create_rating!(socket.assigns.net_id, socket.assigns.id, comment_data)
  end


  def handle_event("save", %{"comment" => comment_form_data}, socket) do
    Logger.info("Received the following form data")
    comment_form_data
    |> inspect()
    |> Logger.info()
    create_comment(comment_form_data, socket)
    {:noreply, socket}
  end

  def handle_event("save", %{"rating" => rating_form_data}, socket) do
    Logger.info("Received the following form data")
    rating_form_data
    |> inspect()
    |> Logger.info()
    create_rating!(rating_form_data, socket)
    {:noreply, socket}
  end
end