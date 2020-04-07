defmodule AppWeb.RatingControllerTest do
  use AppWeb.ConnCase
  alias App.Submissions
  import Plug.Test

  setup [:create_submission]

  @create_attrs %{score: 3}
  @update_attrs %{score: 4}
  @invalid_attrs %{score: nil}

  def fixture(:rating, submission) do
    user_faculty = App.Accounts.get_user_by!("faculty net id")
    {:ok, rating} = Submissions.create_rating!(user_faculty, submission, @create_attrs)
    rating
  end

  # Disabling - no more new rating form, replaced by JS on dropdown on submission page
  #describe "index" do
  #  test "lists all ratings", %{conn: conn, submission: submission} do
  #    conn = conn
  #      |> init_test_session(uid: "faculty net id")
  #      |> get(Routes.submission_rating_path(conn, :index, submission))
  #    assert html_response(conn, 200) =~ "Listing Ratings"
  #  end
  #end

  # Disabling - no more new rating form, replaced by JS on dropdown on submission page
  #describe "new rating" do
  #  test "renders form", %{conn: conn, submission: submission} do
  #    conn = conn
  #      |> init_test_session(uid: "faculty net id")
  #      |> get(Routes.submission_rating_path(conn, :new, submission))
  #    assert html_response(conn, 200) =~ "New Rating"
  #  end
  #end

  describe "create rating" do
    test "redirects to show when data is valid", %{conn: conn, submission: submission} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.submission_rating_path(conn, :create, submission), rating: @create_attrs)

      assert %{submission_id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.submission_path(conn, :show, id)

      conn = get(conn, Routes.submission_path(conn, :show, id))
      assert html_response(conn, 200) =~ Integer.to_string(Map.get(@create_attrs, :score))
    end

    test "renders errors when data is invalid", %{conn: conn, submission: submission} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.submission_rating_path(conn, :create, submission), rating: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Rating"
    end
  end

  describe "edit rating" do
    setup [:create_rating]

    test "renders form for editing chosen rating", %{conn: conn, rating: rating} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.rating_path(conn, :edit, rating))
      assert html_response(conn, 200) =~ "Edit Rating"
    end
  end

  describe "update rating" do
    setup [:create_rating]

    test "redirects when data is valid", %{conn: conn, rating: rating} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> put(Routes.rating_path(conn, :update, rating), rating: @update_attrs)
      assert redirected_to(conn) == Routes.submission_path(conn, :show, rating.submission_id)

      conn = get(conn, Routes.submission_path(conn, :show, rating.submission_id))
      assert html_response(conn, 200) =~ Integer.to_string(Map.get(@update_attrs, :score))
    end

    test "renders errors when data is invalid", %{conn: conn, rating: rating} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> put(Routes.rating_path(conn, :update, rating), rating: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Rating"
    end
  end

  describe "delete rating" do
    setup [:create_rating]

    test "deletes chosen rating", %{conn: conn, rating: rating} do
      submission = Submissions.get_submission!(rating.submission_id)
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> delete(Routes.rating_path(conn, :delete, rating))
      assert redirected_to(conn) == Routes.submission_path(conn, :show, submission)
      assert_raise Ecto.NoResultsError, fn ->
        Submissions.get_rating!(rating.id)
      end
    end
  end

  defp create_rating(params) do
    submission = params.submission
    rating = fixture(:rating, submission)
    {:ok, rating: rating}
  end
  defp create_submission(_) do
    topic = AppWeb.TopicControllerTest.fixture(:topic)
    submission = AppWeb.SubmissionControllerTest.fixture(:submission, topic)
    {:ok, submission: submission}
  end

end
