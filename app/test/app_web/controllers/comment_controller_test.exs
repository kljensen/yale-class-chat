defmodule AppWeb.CommentControllerTest do
  use AppWeb.ConnCase
  alias App.Submissions
  import Plug.Test

  setup [:create_submission]

  @create_attrs %{description: "some description"}
  @update_attrs %{description: "some updated description"}
  @invalid_attrs %{description: nil}

  def fixture(:comment, submission) do
    user_faculty = App.Accounts.get_user_by!("faculty net id")
    {:ok, comment} = Submissions.create_comment(user_faculty, submission, @create_attrs)
    comment
  end

  #describe "index" do
  #  test "lists all comments", %{conn: conn, submission: submission} do
  #    conn = conn
  #      |> init_test_session(uid: "faculty net id")
  #      |> get(Routes.submission_comment_path(conn, :index, submission))
  #    assert html_response(conn, 200) =~ "Listing Comments"
  #  end
  #end

  #Disabling as we no longer have a separate new comment route
  #describe "new comment" do
  #  test "renders form", %{conn: conn, submission: submission} do
  #    conn = conn
  #      |> init_test_session(uid: "faculty net id")
  #      |> get(Routes.submission_comment_path(conn, :new, submission))
  #    assert html_response(conn, 200) =~ "New Comment"
  #  end
  #end

  describe "create comment" do
    test "redirects to show when data is valid", %{conn: conn, submission: submission} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.submission_comment_path(conn, :create, submission), comment: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.submission_path(conn, :show, id)

      conn = get(conn, Routes.submission_path(conn, :show, id))
      assert html_response(conn, 200) =~ @create_attrs.description
    end

    test "renders errors when data is invalid", %{conn: conn, submission: submission} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.submission_comment_path(conn, :create, submission), comment: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Comment"
    end
  end

  describe "edit comment" do
    setup [:create_comment]

    test "renders form for editing chosen comment", %{conn: conn, comment: comment} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.comment_path(conn, :edit, comment))
      assert html_response(conn, 200) =~ "Edit Comment"
    end
  end

  describe "update comment" do
    setup [:create_comment]

    test "redirects when data is valid", %{conn: conn, comment: comment} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> put(Routes.comment_path(conn, :update, comment), comment: @update_attrs)
      assert redirected_to(conn) == Routes.submission_path(conn, :show, comment.submission_id)

      conn = get(conn, Routes.submission_path(conn, :show, comment.submission_id))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, comment: comment} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> put(Routes.comment_path(conn, :update, comment), comment: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Comment"
    end
  end

  describe "delete comment" do
    setup [:create_comment]

    test "deletes chosen comment", %{conn: conn, comment: comment} do
      submission = Submissions.get_submission!(comment.submission_id)
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> delete(Routes.comment_path(conn, :delete, comment))
      assert redirected_to(conn) == Routes.submission_path(conn, :show, submission)
      assert_raise Ecto.NoResultsError, fn ->
        Submissions.get_comment!(comment.id)
      end
    end
  end

  defp create_comment(params) do
    submission = params.submission
    comment = fixture(:comment, submission)
    {:ok, comment: comment}
  end
  defp create_submission(_) do
    topic = AppWeb.TopicControllerTest.fixture(:topic)
    submission = AppWeb.SubmissionControllerTest.fixture(:submission, topic)
    {:ok, submission: submission}
  end

end
