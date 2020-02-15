defmodule AppWeb.SubmissionControllerTest do
  use AppWeb.ConnCase

  alias App.Submissions

  @create_attrs %{description: "some description", image_url: "some image_url", slug: "some slug", title: "some title"}
  @update_attrs %{description: "some updated description", image_url: "some updated image_url", slug: "some updated slug", title: "some updated title"}
  @invalid_attrs %{description: nil, image_url: nil, slug: nil, title: nil}

  def fixture(:submission) do
    {:ok, submission} = Submissions.create_submission(@create_attrs)
    submission
  end

  describe "index" do
    test "lists all submissions", %{conn: conn} do
      conn = get(conn, Routes.submission_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Submissions"
    end
  end

  describe "new submission" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.submission_path(conn, :new))
      assert html_response(conn, 200) =~ "New Submission"
    end
  end

  describe "create submission" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.submission_path(conn, :create), submission: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.submission_path(conn, :show, id)

      conn = get(conn, Routes.submission_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Submission"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.submission_path(conn, :create), submission: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Submission"
    end
  end

  describe "edit submission" do
    setup [:create_submission]

    test "renders form for editing chosen submission", %{conn: conn, submission: submission} do
      conn = get(conn, Routes.submission_path(conn, :edit, submission))
      assert html_response(conn, 200) =~ "Edit Submission"
    end
  end

  describe "update submission" do
    setup [:create_submission]

    test "redirects when data is valid", %{conn: conn, submission: submission} do
      conn = put(conn, Routes.submission_path(conn, :update, submission), submission: @update_attrs)
      assert redirected_to(conn) == Routes.submission_path(conn, :show, submission)

      conn = get(conn, Routes.submission_path(conn, :show, submission))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, submission: submission} do
      conn = put(conn, Routes.submission_path(conn, :update, submission), submission: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Submission"
    end
  end

  describe "delete submission" do
    setup [:create_submission]

    test "deletes chosen submission", %{conn: conn, submission: submission} do
      conn = delete(conn, Routes.submission_path(conn, :delete, submission))
      assert redirected_to(conn) == Routes.submission_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.submission_path(conn, :show, submission))
      end
    end
  end

  defp create_submission(_) do
    submission = fixture(:submission)
    {:ok, submission: submission}
  end
end
