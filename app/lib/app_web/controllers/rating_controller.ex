defmodule AppWeb.RatingController do
  use AppWeb, :controller

  alias App.Submissions
  alias App.Submissions.Rating
  alias App.Submissions.Submission

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
      {:ok, rating} ->
        conn
        |> put_flash(:info, "Rating created successfully.")
        |> redirect(to: Routes.rating_path(conn, :show, rating))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, submission: submission)

      {:error, message} ->
        case message do
          "forbidden" ->
            conn
            |> put_status(:forbidden)
            |> put_view(AppWeb.ErrorView)
            |> render("403.html")
          "not found" ->
            conn
            |> put_status(:not_found)
            |> put_view(AppWeb.ErrorView)
            |> render("404.html")
          _ ->
            changeset = Submissions.change_submission(%Submission{})
            conn
            |> put_flash(:error, message)
            |> render("new.html", changeset: changeset, submission: submission)
          end
    end
  end

  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    case App.Submissions.get_user_rating(user, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(AppWeb.ErrorView)
        |> render("404.html")

      rating ->
        submission = Submissions.get_submission!(rating.submission_id)
        can_edit = App.Accounts.can_edit_rating(user, rating)
        render(conn, "show.html", rating: rating, submission: submission, can_edit: can_edit, uid: user.id)
      end
  end

  def edit(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    case App.Submissions.get_user_rating(user, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(AppWeb.ErrorView)
        |> render("404.html")

      rating ->
        case App.Accounts.can_edit_rating(user, rating) do
          true ->
            submission = Submissions.get_submission!(rating.submission_id)
            changeset = Submissions.change_rating(rating)
            render(conn, "edit.html", rating: rating, changeset: changeset, submission: submission)

          false ->
            conn
            |> put_status(:forbidden)
            |> put_view(AppWeb.ErrorView)
            |> render("403.html")
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
          {:ok, rating} ->
            conn
            |> put_flash(:info, "Rating updated successfully.")
            |> redirect(to: Routes.rating_path(conn, :show, rating))

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "edit.html", rating: rating, changeset: changeset, submission: submission)

          {:error, message} ->
            case message do
              "forbidden" ->
                conn
                |> put_status(:forbidden)
                |> put_view(AppWeb.ErrorView)
                |> render("403.html")
              "not found" ->
                conn
                |> put_status(:not_found)
                |> put_view(AppWeb.ErrorView)
                |> render("404.html")
              _ ->
                changeset = Submissions.change_rating(%Rating{})
                conn
                |> put_flash(:error, message)
                |> render("edit.html", rating: rating, changeset: changeset, submission: submission)
              end
        end

      false ->
        conn
            |> put_status(:forbidden)
            |> put_view(AppWeb.ErrorView)
            |> render("403.html")
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
        |> put_flash(:info, "Rating deleted successfully.")
        |> redirect(to: Routes.submission_rating_path(conn, :index, submission))

      false ->
        conn
            |> put_status(:forbidden)
            |> put_view(AppWeb.ErrorView)
            |> render("403.html")
      end
  end
end
