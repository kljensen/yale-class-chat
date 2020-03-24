defmodule AppWeb.CommentController do
  use AppWeb, :controller

  alias App.Submissions
  alias App.Submissions.Comment

  def index(conn, %{"submission_id" => submission_id}) do
    submission = Submissions.get_submission!(submission_id)
    user = conn.assigns.current_user
    comments = Submissions.list_user_comments(user, submission)
    can_edit = App.Accounts.can_edit_submission(user, submission)
    render(conn, "index.html", comments: comments, submission: submission, can_edit: can_edit)
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
      {:ok, _comment} ->
        conn
        |> put_flash(:success, "Comment created successfully.")
        |> redirect(to: Routes.submission_path(conn, :show, submission))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, submission: submission)

      {:error, message} -> render_error(conn, message)
    end
  end

  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    case App.Submissions.get_user_comment(user, id) do
      {:ok, comment} ->
        submission = Submissions.get_submission!(comment.submission_id)
        can_edit = App.Accounts.can_edit_comment(user, comment)
        render(conn, "show.html", comment: comment, submission: submission, can_edit: can_edit, uid: user.id)

      {:error, message} -> render_error(conn, message)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    case App.Submissions.get_user_comment(user, id) do
      {:ok, comment} ->
        case App.Accounts.can_edit_comment(user, comment) do
          true ->
            submission = Submissions.get_submission!(comment.submission_id)
            changeset = Submissions.change_comment(comment)
            render(conn, "edit.html", comment: comment, changeset: changeset, submission: submission)
          false -> render_error(conn, "forbidden")
        end

      {:error, message} -> render_error(conn, message)
    end
  end

  def update(conn, %{"id" => id, "comment" => comment_params}) do
    user = conn.assigns.current_user
    case App.Submissions.get_user_comment(user, id) do
      {:ok, comment} ->
        case App.Accounts.can_edit_comment(user, comment) do
          true ->
            submission = Submissions.get_submission!(comment.submission_id)
            case Submissions.update_comment(user, comment, comment_params) do
              {:ok, _comment} ->
                conn
                |> put_flash(:success, "Comment updated successfully.")
                |> redirect(to: Routes.submission_path(conn, :show, submission))

              {:error, %Ecto.Changeset{} = changeset} ->
                render(conn, "edit.html", comment: comment, changeset: changeset, submission: submission)

              {:error, message} -> render_error(conn, message)

          false -> render_error(conn, "forbidden")
          end
        end

      {:error, message} -> render_error(conn, message)
      end
  end

  def delete(conn, %{"id" => id}) do
    comment = Submissions.get_comment!(id)
    submission = Submissions.get_submission!(comment.submission_id)
    user = conn.assigns.current_user
    case App.Accounts.can_edit_comment(user, comment) do
      true ->
        {:ok, _comment} = Submissions.delete_comment(user, comment)
        conn
        |> put_flash(:success, "Comment deleted successfully.")
        |> redirect(to: Routes.submission_path(conn, :show, submission))

      false -> render_error(conn, "forbidden")
      end
  end
end
