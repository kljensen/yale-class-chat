defmodule AppWeb.SubmissionControllerTest do
  use AppWeb.ConnCase

  alias App.Submissions
  import Plug.Test

  setup [:create_topic]

  @create_attrs %{description: "some description", image_url: "http://i.imgur.com/u3vyMCW.jpg", title: "some title"}
  @update_attrs %{description: "some updated description", image_url: "http://i.imgur.com/zF7rPAf.jpg", title: "some updated title"}
  @invalid_attrs %{description: nil, image_url: nil, title: nil}

  def fixture(:submission, topic) do
    user_faculty = App.Accounts.get_user_by!("faculty net id")
    {:ok, submission} = Submissions.create_submission!(user_faculty, topic, @create_attrs)
    submission
  end

  #describe "index" do
  #  test "lists all submissions", %{conn: conn, topic: topic} do
  #    conn = conn
  #      |> init_test_session(uid: "faculty net id")
  #      |> get(Routes.topic_submission_path(conn, :index, topic))
  #    assert html_response(conn, 200) =~ "Listing Submissions"
  #  end
  #end

  describe "new submission" do
    test "renders form", %{conn: conn, topic: topic} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.topic_submission_path(conn, :new, topic))
      assert html_response(conn, 200) =~ "New Submission"
    end
  end

  describe "create submission" do
    test "redirects to show when data is valid", %{conn: conn, topic: topic} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.topic_submission_path(conn, :create, topic), submission: @create_attrs)

      assert %{topic_id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.topic_path(conn, :show, topic.id)

      conn = get(conn, Routes.topic_path(conn, :show, topic.id))
      assert html_response(conn, 200) =~ @create_attrs.title
    end

    test "renders errors when data is invalid", %{conn: conn, topic: topic} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.topic_submission_path(conn, :create, topic), submission: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Submission"
    end
  end

  describe "edit submission" do
    setup [:create_submission]

    test "renders form for editing chosen submission", %{conn: conn, submission: submission} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.submission_path(conn, :edit, submission))
      assert html_response(conn, 200) =~ "Edit Submission"
    end
  end

  describe "update submission" do
    setup [:create_submission]

    test "redirects when data is valid", %{conn: conn, submission: submission} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> put(Routes.submission_path(conn, :update, submission), submission: @update_attrs)
      assert redirected_to(conn) == Routes.submission_path(conn, :show, submission)

      conn = get(conn, Routes.submission_path(conn, :show, submission.id))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, submission: submission} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> put(Routes.submission_path(conn, :update, submission), submission: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Submission"
    end
  end

  describe "delete submission" do
    setup [:create_submission]

    test "deletes chosen submission", %{conn: conn, submission: submission, topic: topic} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> delete(Routes.submission_path(conn, :delete, submission))
      assert redirected_to(conn) == Routes.topic_path(conn, :show, topic)
      assert_error_sent 404, fn ->
        get(conn, Routes.submission_path(conn, :show, submission))
      end
    end
  end

  defp create_submission(params) do
    topic = params.topic
    submission = fixture(:submission, topic)
    {:ok, submission: submission}
  end
  defp create_topic(_) do
    topic = AppWeb.TopicControllerTest.fixture(:topic)
    {:ok, topic: topic}
  end
end
