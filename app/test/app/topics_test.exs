defmodule App.TopicsTest do
  use App.DataCase

  alias App.Topics
  alias App.Accounts
  alias App.Courses
  alias App.AccountsTest, as: ATest
  alias App.CoursesTest, as: CTest

  describe "topics" do
    alias App.Topics.Topic

    @valid_attrs %{allow_submission_comments: true, allow_submission_voting: true, allow_submissions: true, anonymous: true, closed_at: "2100-04-17T14:00:00Z", description: "some description", opened_at: "2010-04-17T14:00:00Z", slug: "some slug", sort: "some sort", title: "some title", user_submission_limit: 42, allow_ranking: true, show_user_submissions: true, visible: true}
    @update_attrs %{allow_submission_comments: false, allow_submission_voting: false, allow_submissions: false, anonymous: false, closed_at: "2101-05-18T15:01:01Z", description: "some updated description", opened_at: "2011-05-18T15:01:01Z", slug: "some updated slug", sort: "some updated sort", title: "some updated title", user_submission_limit: 43, allow_ranking: false, show_user_submissions: false, visible: false}
    @invalid_attrs %{allow_submission_comments: nil, allow_submission_voting: nil, allow_submissions: nil, anonymous: nil, closed_at: nil, description: nil, opened_at: nil, slug: nil, sort: nil, title: nil, user_submission_limit: nil, allow_ranking: nil, show_user_submissions: nil, visible: nil}

    def topic_fixture(attrs \\ %{}) do
      params =
        attrs
        |> Enum.into(@valid_attrs)

      section = CTest.section_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")

      {:ok, topic} =
        Topics.create_topic(user_faculty, section, params)

      topic
    end

    test "list_topics/0 returns all topics" do
      topic = topic_fixture()
      retrieved_topics = Topics.list_topics()
      retrieved_1 = List.first(retrieved_topics)
      assert retrieved_1.id == topic.id
    end

    test "get_topic!/1 returns the topic with given id" do
      topic = topic_fixture()
      retrieved_topic = Topics.get_topic!(topic.id)
      assert retrieved_topic.id == topic.id
    end

    test "create_topic/3 with valid data creates a topic" do
      section = CTest.section_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      assert {:ok, %Topic{} = topic} = Topics.create_topic(user_faculty, section, @valid_attrs)
      assert topic.allow_submission_comments == true
      assert topic.allow_submission_voting == true
      assert topic.allow_submissions == true
      assert topic.anonymous == true
      assert topic.closed_at == DateTime.from_naive!(~N[2100-04-17T14:00:00Z], "Etc/UTC")
      assert topic.description == "some description"
      assert topic.opened_at == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert topic.slug == "some slug"
      assert topic.sort == "some sort"
      assert topic.title == "some title"
      assert topic.user_submission_limit == 42
    end

    test "create_topic/3 with invalid data returns error changeset" do
      section = CTest.section_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      assert {:error, changeset = topic} = Topics.create_topic(user_faculty, section, @invalid_attrs)
      assert %{allow_submission_comments: ["can't be blank"]} = errors_on(changeset)
      assert %{allow_submission_voting: ["can't be blank"]} = errors_on(changeset)
      assert %{allow_submissions: ["can't be blank"]} = errors_on(changeset)
      assert %{anonymous: ["can't be blank"]} = errors_on(changeset)
      assert %{description: ["can't be blank"]} = errors_on(changeset)
      assert %{opened_at: ["can't be blank"]} = errors_on(changeset)
      assert %{slug: ["can't be blank"]} = errors_on(changeset)
      assert %{sort: ["can't be blank"]} = errors_on(changeset)
      assert %{title: ["can't be blank"]} = errors_on(changeset)
      assert %{user_submission_limit: ["can't be blank"]} = errors_on(changeset)
      assert %{allow_ranking: ["can't be blank"]} = errors_on(changeset)
      assert %{show_user_submissions: ["can't be blank"]} = errors_on(changeset)
      assert %{visible: ["can't be blank"]} = errors_on(changeset)
    end

    test "create_topic/3 by unauthorized user returns error" do
      section = CTest.section_fixture()
      user_noauth = ATest.user_fixture(%{is_faculty: true, net_id: "new faculty net id"})

      assert {:error, "unauthorized"} = Topics.create_topic(user_noauth, section, @invalid_attrs)
    end

    test "create_topic/3 with non-writeable course returns error" do
      section = CTest.section_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      course = Courses.get_course!(section.course_id)
      Courses.update_course(user_faculty, course, %{allow_write: false})

      assert {:error, "course write not allowed"} = Topics.create_topic(user_faculty, section, @invalid_attrs)
    end

    test "update_topic/2 with valid data updates the topic" do
      topic = topic_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      assert {:ok, %Topic{} = topic} = Topics.update_topic(user_faculty, topic, @update_attrs)
      assert topic.allow_submission_comments == false
      assert topic.allow_submission_voting == false
      assert topic.allow_submissions == false
      assert topic.anonymous == false
      assert topic.closed_at == DateTime.from_naive!(~N[2101-05-18T15:01:01Z], "Etc/UTC")
      assert topic.description == "some updated description"
      assert topic.opened_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert topic.slug == "some updated slug"
      assert topic.sort == "some updated sort"
      assert topic.title == "some updated title"
      assert topic.user_submission_limit == 43
    end

    test "update_topic/2 with invalid data returns error changeset" do
      topic = topic_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      assert {:error, %Ecto.Changeset{}} = Topics.update_topic(user_faculty, topic, @invalid_attrs)
      retrieved_topic = Topics.get_topic!(topic.id)
      assert topic.id == retrieved_topic.id
      assert topic.allow_submission_comments == retrieved_topic.allow_submission_comments
      assert topic.allow_submission_voting == retrieved_topic.allow_submission_voting
      assert topic.allow_submissions == retrieved_topic.allow_submissions
      assert topic.anonymous == retrieved_topic.anonymous
      assert topic.closed_at == retrieved_topic.closed_at
      assert topic.description == retrieved_topic.description
      assert topic.opened_at == retrieved_topic.opened_at
      assert topic.slug == retrieved_topic.slug
      assert topic.sort == retrieved_topic.sort
      assert topic.title == retrieved_topic.title
      assert topic.user_submission_limit == retrieved_topic.user_submission_limit
    end

    test "update_topic/2 by unauthorized user returns error" do
      topic = topic_fixture()
      user_noauth = ATest.user_fixture(%{is_faculty: true, net_id: "new faculty net id"})
      assert {:error, "unauthorized"} = Topics.update_topic(user_noauth, topic, @invalid_attrs)
      retrieved_topic = Topics.get_topic!(topic.id)
      assert topic.id == retrieved_topic.id
      assert topic.allow_submission_comments == retrieved_topic.allow_submission_comments
      assert topic.allow_submission_voting == retrieved_topic.allow_submission_voting
      assert topic.allow_submissions == retrieved_topic.allow_submissions
      assert topic.anonymous == retrieved_topic.anonymous
      assert topic.closed_at == retrieved_topic.closed_at
      assert topic.description == retrieved_topic.description
      assert topic.opened_at == retrieved_topic.opened_at
      assert topic.slug == retrieved_topic.slug
      assert topic.sort == retrieved_topic.sort
      assert topic.title == retrieved_topic.title
      assert topic.user_submission_limit == retrieved_topic.user_submission_limit
    end

    test "update_topic/2 with non-writeable course returns error" do
      topic = topic_fixture()
      section = Courses.get_section!(topic.section_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      course = Courses.get_course!(section.course_id)
      Courses.update_course(user_faculty, course, %{allow_write: false})

      assert {:error, "course write not allowed"} = Topics.update_topic(user_faculty, topic, @update_attrs)
    end

    test "delete_topic/2 deletes the topic" do
      topic = topic_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      assert {:ok, %Topic{}} = Topics.delete_topic(user_faculty, topic)
      assert_raise Ecto.NoResultsError, fn -> Topics.get_topic!(topic.id) end
    end

    test "delete_topic/2 by unauthorized user returns error" do
      topic = topic_fixture()
      user_noauth = ATest.user_fixture(%{is_faculty: true, net_id: "new faculty net id"})
      assert {:error, "unauthorized"} = Topics.delete_topic(user_noauth, topic)
      retrieved_topic = Topics.get_topic!(topic.id)
      assert topic.id == retrieved_topic.id
      assert topic.allow_submission_comments == retrieved_topic.allow_submission_comments
      assert topic.allow_submission_voting == retrieved_topic.allow_submission_voting
      assert topic.allow_submissions == retrieved_topic.allow_submissions
      assert topic.anonymous == retrieved_topic.anonymous
      assert topic.closed_at == retrieved_topic.closed_at
      assert topic.description == retrieved_topic.description
      assert topic.opened_at == retrieved_topic.opened_at
      assert topic.slug == retrieved_topic.slug
      assert topic.sort == retrieved_topic.sort
      assert topic.title == retrieved_topic.title
      assert topic.user_submission_limit == retrieved_topic.user_submission_limit
    end

    test "delete_topic/2 with non-writeable course returns error" do
      topic = topic_fixture()
      section = Courses.get_section!(topic.section_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      course = Courses.get_course!(section.course_id)
      Courses.update_course(user_faculty, course, %{allow_write: false})

      assert {:error, "course write not allowed"} = Topics.delete_topic(user_faculty, topic)
    end

    test "change_topic/1 returns a topic changeset" do
      topic = topic_fixture()
      assert %Ecto.Changeset{} = Topics.change_topic(topic)
    end
  end
end
