defmodule AppWeb.RatingController do
  use AppWeb, :controller

  alias App.Submissions
  alias App.Submissions.Rating

  def index(conn, %{"submission_id" => submission_id}) do
    submission = Submissions.get_submission!(submission_id)
    user = conn.assigns.current_user
    ratings = Submissions.list_user_ratings(user, submission)
    can_edit = App.Accounts.can_edit_submission(user, submission)
    render(conn, "index.html", ratings: ratings, submission: submission, can_edit: can_edit)
  end

  def new(conn, %{"submission_id" => submission_id}) do
    submission = Submissions.get_submission!(submission_id)
    changeset = Submissions.change_rating(%Rating{})
    render(conn, "new.html", changeset: changeset, submission: submission)
  end

  def create(conn, %{"rating" => rating_params, "submission_id" => submission_id}) do
    user = conn.assigns.current_user
    submission = Submissions.get_submission!(submission_id)
    case Submissions.create_rating(user, submission, rating_params) do
      {:ok, _rating} ->
        conn
        |> put_flash(:success, "Rating created successfully.")
        |> redirect(to: Routes.submission_path(conn, :show, submission))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, submission: submission)

      {:error, message} -> render_error(conn, message)
    end
  end

  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    case App.Submissions.get_user_rating(user, id) do
      nil -> render_error(conn, "not found")

      rating ->
        submission = Submissions.get_submission!(rating.submission_id)
        can_edit = App.Accounts.can_edit_rating(user, rating)
        render(conn, "show.html", rating: rating, submission: submission, can_edit: can_edit, uid: user.id)
      end
  end

  def edit(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    case App.Submissions.get_user_rating(user, id) do
      nil -> render_error(conn, "not found")

      rating ->
        case App.Accounts.can_edit_rating(user, rating) do
          true ->
            submission = Submissions.get_submission!(rating.submission_id)
            changeset = Submissions.change_rating(rating)
            render(conn, "edit.html", rating: rating, changeset: changeset, submission: submission)

          false -> render_error(conn, "forbidden")
        end
      end
  end

  def update(conn, %{"id" => id, "rating" => rating_params}) do
    rating = Submissions.get_rating!(id)
    user = conn.assigns.current_user
    case App.Accounts.can_edit_rating(user, rating) do
      true ->
        submission = Submissions.get_submission!(rating.submission_id)
        case Submissions.update_rating(user, rating, rating_params) do
          {:ok, _rating} ->
            conn
            |> put_flash(:success, "Rating updated successfully.")
            |> redirect(to: Routes.submission_path(conn, :show, submission))

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "edit.html", rating: rating, changeset: changeset, submission: submission)

          {:error, message} -> render_error(conn, message)
        end

      false -> render_error(conn, "forbidden")
      end
  end

  def delete(conn, %{"id" => id}) do
    rating = Submissions.get_rating!(id)
    submission = Submissions.get_submission!(rating.submission_id)
    user = conn.assigns.current_user

    case App.Accounts.can_edit_rating(user, rating) do
      true ->
        {:ok, _rating} = Submissions.delete_rating(user, rating)
        conn
        |> put_flash(:success, "Rating deleted successfully.")
        |> redirect(to: Routes.submission_path(conn, :show, submission))

      false -> render_error(conn, "forbidden")
      end
  end
end
