defmodule SubmissionLiveComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div id="user-<%= @id %>">
        Submission will go here
    </div>
    """
  end
end