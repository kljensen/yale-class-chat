defmodule SubmissionLiveComponent do
  use Phoenix.LiveComponent
  alias App.Submissions.Submission
  require Logger

  def render(assigns) do
    Phoenix.View.render(AppWeb.TopicView, "submission_card.html", assigns)
  end

  @doc """
  Subscribe to database updates for this submission. Notice that
  the updates are not handled by this component but instead are
  handled by the LiveView parent in which it runs. As I'm writing
  this, that is `TopicLive`. Events will be handled by `handle_info`
  in `TopicLive` which will update state and those state changes 
  will percolate down to here. Notice also that if this submission
  is deleted, the `TopicLive` will need to `unsubscribe` to 
  notifications.
  """
  defp subscribe(id) do
    notification_topic = App.Notifications.key_for_model_and_id(Submission, id)
    {Phoenix.PubSub.subscribe(App.PubSub, notification_topic), notification_topic}
  end

  @doc """
  Set initial state, called once when the component
  is first rendered. We set up our event listeners
  here. As far as I can tell, the liveview socket
  is in a connected state `connected?(socket) === true`
  when this `mount/1` is called.
  """
  def mount(socket) do
    # {:ok, topic_name} = subscribe(id)
    socket
    |> inspect(limit: :infinity, printable_limit: :infinity)
    |> Logger.info()
    {:ok, socket}
  end

  @doc """
  Called after `mount/1` for the component. This is the method by
  which we merge the parameters passed to `live_component` into
  the `socket.assigns`. If you don't define this function, that
  is the default behavior.
  """
  def update(assigns, socket) do
    Logger.info("Inside update of SubmissionLiveComponent")
    {:ok, assign(socket, assigns)}
  end
end