defmodule AppWeb.CommentController do
  use AppWeb, :controller

  alias App.Submissions
  alias App.Submissions.Comment
  alias App.Submissions.Submission

  def index(conn, %{"submission_id" => submission_id}) do
    submission = Submissions.get_submission!(submission_id)
    user = conn.assigns.current_user
    comments = Submissions.list_user_comments(user, submission)
    render(conn, "index.html", comments: comments, submission: submission)
  end

  def new(conn, %{"submission_id" => submission_id}) do
    submission = Submissions.get_submission!(submission_id)
    changeset = Submissions.change_comment(%Comment{})
    render(conn, "new.html", changeset: changeset, submission: submission)
  end

  def create(conn, %{"comment" => comment_params, "submission_id" => submission_id}) do
    user = conn.assigns.current_user
    submission = Submissions.get_submission!(submission_id)
    case Submissions.create_comment(user, submission, comment_params) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment created successfully.")
        |> redirect(to: Routes.comment_path(conn, :show, comment))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, submission: submission)

      {:error, message} ->
        changeset = Submissions.change_submission(%Submission{})
        conn
        |> put_flash(:error, message)
        |> render("new.html", changeset: changeset, submission: submission)
    end
  end

  def show(conn, %{"id" => id}) do
    comment = Submissions.get_comment!(id)
    submission = Submissions.get_submission!(comment.submission_id)
    render(conn, "show.html", comment: comment, submission: submission)
  end

  def edit(conn, %{"id" => id}) do
    comment = Submissions.get_comment!(id)
    submission = Submissions.get_submission!(comment.submission_id)
    changeset = Submissions.change_comment(comment)
    render(conn, "edit.html", comment: comment, changeset: changeset, submission: submission)
  end

  def update(conn, %{"id" => id, "comment" => comment_params}) do
    comment = Submissions.get_comment!(id)
    submission = Submissions.get_submission!(comment.submission_id)
    user = conn.assigns.current_user
    case Submissions.update_comment(user, comment, comment_params) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment updated successfully.")
        |> redirect(to: Routes.comment_path(conn, :show, comment))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", comment: comment, changeset: changeset, submission: submission)

      {:error, message} ->
        changeset = Submissions.change_comment(%Comment{})
        conn
        |> put_flash(:error, message)
        |> render("edit.html", comment: comment, changeset: changeset, submission: submission)
    end
  end

  def delete(conn, %{"id" => id}) do
    comment = Submissions.get_comment!(id)
    submission = Submissions.get_submission!(comment.submission_id)
    user = conn.assigns.current_user
    {:ok, _comment} = Submissions.delete_comment(user, comment)

    conn
    |> put_flash(:info, "Comment deleted successfully.")
    |> redirect(to: Routes.submission_comment_path(conn, :index, submission))
  end
end
