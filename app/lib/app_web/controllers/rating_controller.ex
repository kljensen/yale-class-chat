defmodule AppWeb.RatingController do
  use AppWeb, :controller

  alias App.Submissions
  alias App.Submissions.Rating
  alias App.Submissions.Submission

  def index(conn, %{"submission_id" => submission_id}) do
    submission = Submissions.get_submission!(submission_id)
    user = conn.assigns.current_user
    ratings = Submissions.list_user_ratings(user, submission)
    render(conn, "index.html", ratings: ratings, submission: submission)
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
      {:ok, rating} ->
        conn
        |> put_flash(:info, "Rating created successfully.")
        |> redirect(to: Routes.rating_path(conn, :show, rating))

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
    rating = Submissions.get_rating!(id)
    submission = Submissions.get_submission!(rating.submission_id)
    render(conn, "show.html", rating: rating, submission: submission)
  end

  def edit(conn, %{"id" => id}) do
    rating = Submissions.get_rating!(id)
    submission = Submissions.get_submission!(rating.submission_id)
    changeset = Submissions.change_rating(rating)
    render(conn, "edit.html", rating: rating, changeset: changeset, submission: submission)
  end

  def update(conn, %{"id" => id, "rating" => rating_params}) do
    rating = Submissions.get_rating!(id)
    submission = Submissions.get_submission!(rating.submission_id)
    user = conn.assigns.current_user
    case Submissions.update_rating(user, rating, rating_params) do
      {:ok, rating} ->
        conn
        |> put_flash(:info, "Rating updated successfully.")
        |> redirect(to: Routes.rating_path(conn, :show, rating))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", rating: rating, changeset: changeset, submission: submission)

      {:error, message} ->
        changeset = Submissions.change_rating(%Rating{})
        conn
        |> put_flash(:error, message)
        |> render("edit.html", rating: rating, changeset: changeset, submission: submission)
    end
  end

  def delete(conn, %{"id" => id}) do
    rating = Submissions.get_rating!(id)
    submission = Submissions.get_submission!(rating.submission_id)
    user = conn.assigns.current_user
    {:ok, _rating} = Submissions.delete_rating(user, rating)

    conn
    |> put_flash(:info, "Rating deleted successfully.")
    |> redirect(to: Routes.submission_rating_path(conn, :index, submission))
  end
end
