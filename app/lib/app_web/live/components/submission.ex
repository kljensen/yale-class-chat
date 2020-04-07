defmodule SubmissionLiveComponent do
  use Phoenix.LiveComponent
  alias App.Submissions.Submission
  require Logger

  def render(assigns) do
    Phoenix.View.render(AppWeb.TopicView, "submission_card.html", assigns)
  end

  @doc """
  Set initial state, called once when the component
  is first rendered. We set up our event listeners
  here. As far as I can tell, the liveview socket
  is in a connected state `connected?(socket) === true`
  when this `mount/1` is called.
  """
  def mount(socket) do
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