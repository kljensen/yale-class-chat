defmodule AppWeb.TopicControllerTest do
  use AppWeb.ConnCase

  alias App.Topics

  @create_attrs %{allow_submission_comments: true, allow_submission_voting: true, allow_submissions: true, anonymous: true, closed_at: "2010-04-17T14:00:00Z", description: "some description", opened_at: "2010-04-17T14:00:00Z", slug: "some slug", sort: "some sort", title: "some title", user_submission_limit: 42}
  @update_attrs %{allow_submission_comments: false, allow_submission_voting: false, allow_submissions: false, anonymous: false, closed_at: "2011-05-18T15:01:01Z", description: "some updated description", opened_at: "2011-05-18T15:01:01Z", slug: "some updated slug", sort: "some updated sort", title: "some updated title", user_submission_limit: 43}
  @invalid_attrs %{allow_submission_comments: nil, allow_submission_voting: nil, allow_submissions: nil, anonymous: nil, closed_at: nil, description: nil, opened_at: nil, slug: nil, sort: nil, title: nil, user_submission_limit: nil}

  def fixture(:topic) do
    {:ok, topic} = Topics.create_topic(@create_attrs)
    topic
  end

  describe "index" do
    @tag :skip
    test "lists all topics", %{conn: conn} do
      conn = get(conn, Routes.topic_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Topics"
    end
  end

  describe "new topic" do
    @tag :skip
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.topic_path(conn, :new))
      assert html_response(conn, 200) =~ "New Topic"
    end
  end

  describe "create topic" do
    @tag :skip
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.topic_path(conn, :create), topic: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.topic_path(conn, :show, id)

      conn = get(conn, Routes.topic_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Topic"
    end

    @tag :skip
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.topic_path(conn, :create), topic: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Topic"
    end
  end

  describe "edit topic" do
    setup [:create_topic]

    @tag :skip
    test "renders form for editing chosen topic", %{conn: conn, topic: topic} do
      conn = get(conn, Routes.topic_path(conn, :edit, topic))
      assert html_response(conn, 200) =~ "Edit Topic"
    end
  end

  describe "update topic" do
    setup [:create_topic]

    @tag :skip
    test "redirects when data is valid", %{conn: conn, topic: topic} do
      conn = put(conn, Routes.topic_path(conn, :update, topic), topic: @update_attrs)
      assert redirected_to(conn) == Routes.topic_path(conn, :show, topic)

      conn = get(conn, Routes.topic_path(conn, :show, topic))
      assert html_response(conn, 200) =~ "some updated description"
    end

    @tag :skip
    test "renders errors when data is invalid", %{conn: conn, topic: topic} do
      conn = put(conn, Routes.topic_path(conn, :update, topic), topic: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Topic"
    end
  end

  describe "delete topic" do
    setup [:create_topic]

    @tag :skip
    test "deletes chosen topic", %{conn: conn, topic: topic} do
      conn = delete(conn, Routes.topic_path(conn, :delete, topic))
      assert redirected_to(conn) == Routes.topic_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.topic_path(conn, :show, topic))
      end
    end
  end

  defp create_topic(_) do
    topic = fixture(:topic)
    {:ok, topic: topic}
  end
end
