defmodule AppWeb.SubmissionController do
  use AppWeb, :controller

  alias App.Submissions
  alias App.Submissions.Submission
  alias App.Topics

  def index(conn, %{"topic_id" => topic_id}) do
    topic = Topics.get_topic!(topic_id)
    user = conn.assigns.current_user
    submissions = Submissions.list_user_submissions(user, topic)
    render(conn, "index.html", submissions: submissions, topic: topic)
  end

  def new(conn, %{"topic_id" => topic_id}) do
    changeset = Submissions.change_submission(%Submission{})
    topic = Topics.get_topic!(topic_id)
    render(conn, "new.html", changeset: changeset, topic: topic)
  end

  def create(conn, %{"submission" => submission_params, "topic_id" => topic_id}) do
    user = conn.assigns.current_user
    topic = Topics.get_topic!(topic_id)

    case Submissions.create_submission(user, topic, submission_params) do
      {:ok, submission} ->
        conn
        |> put_flash(:info, "Submission created successfully.")
        |> redirect(to: Routes.submission_path(conn, :show, submission))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, topic: topic)

      {:error, message} ->
        changeset = Submissions.change_submission(%Submission{})
        conn
        |> put_flash(:error, message)
        |> render("new.html", changeset: changeset, topic: topic)

    end
  end

  def show(conn, %{"id" => id}) do
    submission = Submissions.get_submission!(id)
    topic = Topics.get_topic!(submission.topic_id)
    render(conn, "show.html", submission: submission, topic: topic)
  end

  def edit(conn, %{"id" => id}) do
    submission = Submissions.get_submission!(id)
    changeset = Submissions.change_submission(submission)
    render(conn, "edit.html", submission: submission, changeset: changeset)
  end

  def update(conn, %{"id" => id, "submission" => submission_params}) do
    submission = Submissions.get_submission!(id)
    topic = Topics.get_topic!(submission.topic_id)
    user = conn.assigns.current_user

    case Submissions.update_submission(user, submission, submission_params) do
      {:ok, submission} ->
        conn
        |> put_flash(:info, "Submission updated successfully.")
        |> redirect(to: Routes.submission_path(conn, :show, submission))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", submission: submission, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    submission = Submissions.get_submission!(id)
    topic = Topics.get_topic!(submission.topic_id)
    user = conn.assigns.current_user
    {:ok, _submission} = Submissions.delete_submission(user, submission)

    conn
    |> put_flash(:info, "Submission deleted successfully.")
    |> redirect(to: Routes.topic_submission_path(conn, :index, topic))
  end
end
