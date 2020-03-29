defmodule AppWeb.SubmissionLive do
  use Phoenix.LiveView
  require Logger
  require Phoenix.PubSub
  require App.LiveViewNotifications
  alias App.Submissions.Submission


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
    Logger.info("About to load submission data")
    socket.assigns
    |> inspect()
    |> Logger.info()
    submission_data = App.Submissions.get_submission_data_for_net_id!(net_id, id)
    assign(socket, submission_data)
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
      # App.LiveViewNotifications.subscribe_for_submission(id)
    end

    socket = socket 
    |> assign(:id, id)
    |> assign(:net_id, net_id)
    |> assign(:conn, AppWeb.Endpoint)
    |> load_submission_data(net_id, id)

    # Here, I fake the conn based on the suggestion in github:
    # https://github.com/phoenixframework/phoenix_live_view/issues/277
    # It seems to work but doesn't feel right. Mostly this is to get
    # `Routes.submission_submission_path(@conn, :new, @submission.id)` to work.
    # I think that's the only way in which I'm depending on the @conn.
    # TODO: refactor. One easy way is to pre-load all the routes we
    # need into assigns.

    {:ok, socket}
  end

  def handle_info(action, socket) do
    Logger.info("\n\n\n>>>>Updating liveview")
    action
    |> inspect()
    |> Logger.info()
    {:noreply, load_submission_data(socket)}
  end

end