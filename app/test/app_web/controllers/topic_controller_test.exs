defmodule AppWeb.TopicControllerTest do
  use AppWeb.ConnCase

  alias App.Topics
  import Plug.Test
  import AppWeb.ControllerHelpers

  @create_attrs %{allow_submission_comments: true, allow_submission_voting: true, allow_submissions: true, anonymous: true, closed_at: "2120-04-08T17:36", description: "some description", opened_at: "2020-03-08T17:36", slug: "some slug", sort: "some sort", title: "some title", user_submission_limit: 42, visible: true, show_user_submissions: true, type: "general"}
  @update_attrs %{allow_submission_comments: false, allow_submission_voting: false, allow_submissions: false, anonymous: false, closed_at: "2019-04-08T17:36", description: "some updated description", opened_at: "2020-04-08T17:36", slug: "some updated slug", sort: "some updated sort", title: "some updated title", user_submission_limit: 43, visible: false, show_user_submissions: false, type: "qa"}
  @invalid_attrs %{allow_submission_comments: nil, allow_submission_voting: nil, allow_submissions: nil, anonymous: nil, closed_at: "2019-04-08T17:36", description: nil, opened_at: "2020-04-08T17:36", slug: nil, sort: nil, title: nil, user_submission_limit: nil, visible: nil, show_user_submissions: nil}

  def fixture(:topic) do
    section = AppWeb.SectionControllerTest.fixture(:section)
    user_faculty = App.Accounts.get_user_by!("faculty net id")
    {:ok, topic} = Topics.create_topic!(user_faculty, section, @create_attrs)
    topic
  end

  #describe "index" do
  #  setup [:create_section]
  #
  #  test "lists all topics", %{conn: conn, section: section} do
  #    conn = conn
  #      |> init_test_session(uid: "faculty net id")
  #      |> get(Routes.section_topic_path(conn, :index, section))
  #    assert html_response(conn, 200) =~ "Listing Topics"
  #  end
  #end

  describe "new topic" do
    setup [:create_section]

    test "renders form", %{conn: conn, section: section} do
      course = App.Courses.get_course!(section.course_id)
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.course_topic_path(conn, :new, course))
      assert html_response(conn, 200) =~ "New Topic"
    end
  end

  describe "create topic" do
    setup [:create_section]

    test "creates topic with correct vars", %{conn: conn, section: section} do
      course = App.Courses.get_course!(section.course_id)
      section_ids = [Integer.to_string(section.id)]
      attrs = Map.merge(@create_attrs, %{sections: section_ids})
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.course_topic_path(conn, :create, course), topic: attrs)

      assert %{topic_id: id} = redirected_params(conn)
      topic = Topics.get_topic!(id)
      attrstest = Map.put(@create_attrs, :opened_at, convert_NYC_datetime_to_db!(@create_attrs.opened_at))
      attrstest = Map.put(attrstest, :closed_at, convert_NYC_datetime_to_db!(@create_attrs.closed_at))
      Enum.each  attrstest,  fn {k, v} ->
        assert Map.get(topic, k) == v
      end

    end

    test "redirects to show when data is valid", %{conn: conn, section: section} do
      course = App.Courses.get_course!(section.course_id)
      section_ids = [Integer.to_string(section.id)]
      attrs = Map.merge(@create_attrs, %{sections: section_ids})
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.course_topic_path(conn, :create, course), topic: attrs)

      assert %{topic_id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.topic_path(conn, :show, id)

      conn = get(conn, Routes.topic_path(conn, :show, id))
      assert html_response(conn, 200) =~ @create_attrs.title
    end

    test "creates exactly one topic per selected section", %{conn: conn, section: section} do
      course = App.Courses.get_course!(section.course_id)
      user_faculty = App.Accounts.get_user_by!("faculty net id")
      {:ok, section2} = App.Courses.create_section(user_faculty, course, %{crn: "some updated crn", title: "some updated title"})
      section_ids = [Integer.to_string(section.id), Integer.to_string(section2.id)]
      attrs = Map.merge(@create_attrs, %{sections: section_ids})
      conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.course_topic_path(conn, :create, course), topic: attrs)

      assert length(App.Topics.list_topics(section)) == 1
      assert length(App.Topics.list_topics(section2)) == 1
    end

    test "renders errors when data is invalid", %{conn: conn, section: section} do
      course = App.Courses.get_course!(section.course_id)
      section_ids = [Integer.to_string(section.id)]
      attrs = Map.merge(@invalid_attrs, %{section_ids: section_ids})
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.course_topic_path(conn, :create, course), topic: attrs)
      assert html_response(conn, 200) =~ "New Topic"
    end
  end

  describe "edit topic" do
    setup [:create_topic]

    test "renders form for editing chosen topic", %{conn: conn, topic: topic} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.topic_path(conn, :edit, topic))
      assert html_response(conn, 200) =~ "Edit Topic"
    end
  end

  describe "update topic" do
    setup [:create_topic]

    test "redirects when data is valid", %{conn: conn, topic: topic} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> put(Routes.topic_path(conn, :update, topic), topic: @update_attrs)
      assert redirected_to(conn) == Routes.topic_path(conn, :show, topic)

      conn = get(conn, Routes.topic_path(conn, :show, topic))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, topic: topic} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> put(Routes.topic_path(conn, :update, topic), topic: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Topic"
    end
  end

  describe "delete topic" do
    setup [:create_topic]

    test "deletes chosen topic", %{conn: conn, topic: topic} do
      section = App.Courses.get_section!(topic.section_id)
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> delete(Routes.topic_path(conn, :delete, topic))

      assert redirected_to(conn) == Routes.section_path(conn, :show, section)
      assert_raise Ecto.NoResultsError, fn ->
        Topics.get_topic!(topic.id)
      end
    end
  end

  defp create_topic(_) do
    topic = fixture(:topic)
    {:ok, topic: topic}
  end

  defp create_section(_) do
    section = AppWeb.SectionControllerTest.fixture(:section)
    {:ok, section: section}
  end
end
