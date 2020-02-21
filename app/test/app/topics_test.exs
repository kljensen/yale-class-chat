defmodule App.TopicsTest do
  use App.DataCase

  alias App.Topics
  alias App.CoursesTest, as: CTest

  describe "topics" do
    alias App.Topics.Topic

    @valid_attrs %{allow_submission_comments: true, allow_submission_voting: true, allow_submissions: true, anonymous: true, closed_at: "2010-04-17T14:00:00Z", description: "some description", opened_at: "2010-04-17T14:00:00Z", slug: "some slug", sort: "some sort", title: "some title", user_submission_limit: 42}
    @update_attrs %{allow_submission_comments: false, allow_submission_voting: false, allow_submissions: false, anonymous: false, closed_at: "2011-05-18T15:01:01Z", description: "some updated description", opened_at: "2011-05-18T15:01:01Z", slug: "some updated slug", sort: "some updated sort", title: "some updated title", user_submission_limit: 43}
    @invalid_attrs %{allow_submission_comments: nil, allow_submission_voting: nil, allow_submissions: nil, anonymous: nil, closed_at: nil, description: nil, opened_at: nil, slug: nil, sort: nil, title: nil, user_submission_limit: nil}

    def topic_fixture(attrs \\ %{}) do
      params =
        attrs
        |> Enum.into(@valid_attrs)

      section = CTest.section_fixture()

      {:ok, topic} =
        Topics.create_topic(section, params)

      topic
    end

    test "list_topics/0 returns all topics" do
      topic = topic_fixture()
      retrieved_topics = Topics.list_topics()
      retrieved_1 = Enum.fetch(retrieved_topics, 1)
      assert retrieved_1.id == topic.id
    end

    test "get_topic!/1 returns the topic with given id" do
      topic = topic_fixture()
      retrieved_topic = Topics.get_topic!(topic.id)
      assert retrieved_topic.id == topic.id
    end

    test "create_topic/1 with valid data creates a topic" do
      section = CTest.section_fixture()
      assert {:ok, %Topic{} = topic} = Topics.create_topic(section, @valid_attrs)
      assert topic.allow_submission_comments == true
      assert topic.allow_submission_voting == true
      assert topic.allow_submissions == true
      assert topic.anonymous == true
      assert topic.closed_at == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert topic.description == "some description"
      assert topic.opened_at == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert topic.slug == "some slug"
      assert topic.sort == "some sort"
      assert topic.title == "some title"
      assert topic.user_submission_limit == 42
    end

    test "create_topic/1 with invalid data returns error changeset" do
      section = CTest.section_fixture()
      assert {:error, changeset = topic} = Topics.create_topic(section, @invalid_attrs)
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
    end

    test "update_topic/2 with valid data updates the topic" do
      topic = topic_fixture()
      assert {:ok, %Topic{} = topic} = Topics.update_topic(topic, @update_attrs)
      assert topic.allow_submission_comments == false
      assert topic.allow_submission_voting == false
      assert topic.allow_submissions == false
      assert topic.anonymous == false
      assert topic.closed_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert topic.description == "some updated description"
      assert topic.opened_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert topic.slug == "some updated slug"
      assert topic.sort == "some updated sort"
      assert topic.title == "some updated title"
      assert topic.user_submission_limit == 43
    end

    test "update_topic/2 with invalid data returns error changeset" do
      topic = topic_fixture()
      assert {:error, %Ecto.Changeset{}} = Topics.update_topic(topic, @invalid_attrs)
      assert topic == Topics.get_topic!(topic.id)
    end

    test "delete_topic/1 deletes the topic" do
      topic = topic_fixture()
      assert {:ok, %Topic{}} = Topics.delete_topic(topic)
      assert_raise Ecto.NoResultsError, fn -> Topics.get_topic!(topic.id) end
    end

    test "change_topic/1 returns a topic changeset" do
      topic = topic_fixture()
      assert %Ecto.Changeset{} = Topics.change_topic(topic)
    end
  end
end
