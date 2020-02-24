defmodule App.SubmissionsTest do
  use App.DataCase
  #@moduletag :working
  alias App.Submissions
  alias App.Topics
  alias App.Courses
  alias App.Accounts
  alias App.TopicsTest, as: TTest
  alias App.AccountsTest, as: ATest


  setup [:create_topic]

  defp create_topic(_context) do
    topic = TTest.topic_fixture()
    section = App.Courses.get_section!(topic.section_id)
    user_faculty = Accounts.get_user_by!("faculty net id")
    submitter = ATest.user_fixture(%{net_id: "submitter"})
    {:ok, current_time} = DateTime.now("Etc/UTC")
    role = role_fixture()
    App.Accounts.create_section__role(user_faculty, submitter, section, role)


    [topic: topic, section: section, user_faculty: user_faculty, submitter: submitter]
  end

  

  describe "submissions" do
    alias App.Submissions.Submission

    @valid_attrs %{description: "some description", image_url: "some image_url", slug: "some slug", title: "some title"}
    @update_attrs %{description: "some updated description", image_url: "some updated image_url", slug: "some updated slug", title: "some updated title"}
    @invalid_attrs %{description: nil, image_url: nil, slug: nil, title: nil}


    def role_fixture(attrs \\ %{}) do
      {:ok, current_time} = DateTime.now("Etc/UTC")
      defaults = %{role: "student", valid_from: current_time, valid_to: "2100-01-01T00:00:00Z"}

      params =
        attrs
        |> Enum.into(defaults)

      params
    end

    def submission_fixture(submitter, topic, attrs \\ %{}) do
      params =
        attrs
        |> Enum.into(@valid_attrs)

      {:ok, submission} =
        Submissions.create_submission(submitter, topic, params)

      submission
    end

    test "list_submissions/0 returns all submissions", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      retrieved_submissions = Submissions.list_submissions()
      retrieved_submission = List.first(retrieved_submissions)
      assert retrieved_submission.id == submission.id
      assert retrieved_submission.description == submission.description
      assert retrieved_submission.image_url == submission.image_url
      assert retrieved_submission.slug == submission.slug
      assert retrieved_submission.title == submission.title      
    end

    test "get_submission!/1 returns the submission with given id", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      retrieved_submission = Submissions.get_submission!(submission.id)
      assert retrieved_submission.id == submission.id
      assert retrieved_submission.description == submission.description
      assert retrieved_submission.image_url == submission.image_url
      assert retrieved_submission.slug == submission.slug
      assert retrieved_submission.title == submission.title
    end

    test "create_submission/3 with valid data creates a submission", context do
      submitter = context[:submitter]
      topic = context[:topic]

      assert {:ok, %Submission{} = submission} = Submissions.create_submission(submitter, topic, @valid_attrs)
      assert submission.description == "some description"
      assert submission.image_url == "some image_url"
      assert submission.slug == "some slug"
      assert submission.title == "some title"
    end

    test "create_submission/3 with invalid data returns error changeset", context do
      submitter = context[:submitter]
      topic = context[:topic]
      assert {:error, changeset = submission} = Submissions.create_submission(submitter, topic, @invalid_attrs)
      assert %{title: ["can't be blank"]} = errors_on(changeset)
      assert %{description: ["can't be blank"]} = errors_on(changeset)
      assert %{slug: ["can't be blank"]} = errors_on(changeset)
    end

    test "create_submission/3 with unauthorized user returns error", context do
      user_noauth = ATest.user_fixture(%{is_faculty: true, net_id: "new faculty net id"})
      topic = context[:topic]
      assert {:error, "unauthorized"} = Submissions.create_submission(user_noauth, topic, @invalid_attrs)
    end

    test "update_submission/3 with valid data updates the submission", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      submitter = context[:submitter]
      assert {:ok, %Submission{} = submission} = Submissions.update_submission(submitter, submission, @update_attrs)
      assert submission.description == "some updated description"
      assert submission.image_url == "some updated image_url"
      assert submission.slug == "some updated slug"
      assert submission.title == "some updated title"
    end

    test "update_submission/3 with invalid data returns error changeset", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      submitter = context[:submitter]
      assert {:error, %Ecto.Changeset{}} = Submissions.update_submission(submitter, submission, @invalid_attrs)
      retrieved_submission = Submissions.get_submission!(submission.id)
      assert retrieved_submission.id == submission.id
      assert retrieved_submission.description == submission.description
      assert retrieved_submission.image_url == submission.image_url
      assert retrieved_submission.slug == submission.slug
      assert retrieved_submission.title == submission.title
    end

    test "update_submission/3 with unauthorized user returns error", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      user_noauth = ATest.user_fixture(%{is_faculty: true, net_id: "new faculty net id"})
      assert {:error, "unauthorized"} = Submissions.update_submission(user_noauth, submission, @invalid_attrs)
      retrieved_submission = Submissions.get_submission!(submission.id)
      assert retrieved_submission.id == submission.id
      assert retrieved_submission.description == submission.description
      assert retrieved_submission.image_url == submission.image_url
      assert retrieved_submission.slug == submission.slug
      assert retrieved_submission.title == submission.title
    end

    test "delete_submission/2 deletes the submission", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      submitter = context[:submitter]
      assert {:ok, %Submission{}} = Submissions.delete_submission(submitter, submission)
      assert_raise Ecto.NoResultsError, fn -> Submissions.get_submission!(submission.id) end
    end

    test "delete_submission/2 with unauthorized user returns error", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      user_noauth = ATest.user_fixture(%{is_faculty: true, net_id: "new faculty net id"})
      assert {:error, "unauthorized"} = Submissions.delete_submission(user_noauth, submission)
      retrieved_submission = Submissions.get_submission!(submission.id)
      assert retrieved_submission.id == submission.id
      assert retrieved_submission.description == submission.description
      assert retrieved_submission.image_url == submission.image_url
      assert retrieved_submission.slug == submission.slug
      assert retrieved_submission.title == submission.title
    end

    test "change_submission/1 returns a submission changeset", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      assert %Ecto.Changeset{} = Submissions.change_submission(submission)
    end
  end

  describe "comments" do
    alias App.Submissions.Comment

    @valid_attrs %{description: "some description", title: "some title"}
    @update_attrs %{description: "some updated description", title: "some updated title"}
    @invalid_attrs %{description: nil, title: nil}

    def comment_fixture(attrs \\ %{}) do
      {:ok, comment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Submissions.create_comment()

      comment
    end

    test "list_comments/0 returns all comments" do
      comment = comment_fixture()
      assert Submissions.list_comments() == [comment]
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()
      assert Submissions.get_comment!(comment.id) == comment
    end

    test "create_comment/1 with valid data creates a comment" do
      assert {:ok, %Comment{} = comment} = Submissions.create_comment(@valid_attrs)
      assert comment.description == "some description"
      assert comment.title == "some title"
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, changeset = comment} = Submissions.create_comment(@invalid_attrs)
      assert %{title: ["can't be blank"]} = errors_on(changeset)
      assert %{description: ["can't be blank"]} = errors_on(changeset)
    end

    test "update_comment/2 with valid data updates the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{} = comment} = Submissions.update_comment(comment, @update_attrs)
      assert comment.description == "some updated description"
      assert comment.title == "some updated title"
    end

    test "update_comment/2 with invalid data returns error changeset" do
      comment = comment_fixture()
      assert {:error, %Ecto.Changeset{}} = Submissions.update_comment(comment, @invalid_attrs)
      assert comment == Submissions.get_comment!(comment.id)
    end

    test "delete_comment/1 deletes the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{}} = Submissions.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Submissions.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset" do
      comment = comment_fixture()
      assert %Ecto.Changeset{} = Submissions.change_comment(comment)
    end
  end

  describe "ratings" do
    alias App.Submissions.Rating

    @valid_attrs %{score: 42}
    @update_attrs %{score: 43}
    @invalid_attrs %{score: nil}

    def rating_fixture(attrs \\ %{}) do
      {:ok, rating} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Submissions.create_rating()

      rating
    end

    test "list_ratings/0 returns all ratings" do
      rating = rating_fixture()
      assert Submissions.list_ratings() == [rating]
    end

    test "get_rating!/1 returns the rating with given id" do
      rating = rating_fixture()
      assert Submissions.get_rating!(rating.id) == rating
    end

    test "create_rating/1 with valid data creates a rating" do
      assert {:ok, %Rating{} = rating} = Submissions.create_rating(@valid_attrs)
      assert rating.score == 42
    end

    test "create_rating/1 with invalid data returns error changeset" do
      assert {:error, changeset = rating} = Submissions.create_rating(@invalid_attrs)
      assert %{score: ["can't be blank"]} = errors_on(changeset)
    end

    test "update_rating/2 with valid data updates the rating" do
      rating = rating_fixture()
      assert {:ok, %Rating{} = rating} = Submissions.update_rating(rating, @update_attrs)
      assert rating.score == 43
    end

    test "update_rating/2 with invalid data returns error changeset" do
      rating = rating_fixture()
      assert {:error, %Ecto.Changeset{}} = Submissions.update_rating(rating, @invalid_attrs)
      assert rating == Submissions.get_rating!(rating.id)
    end

    test "delete_rating/1 deletes the rating" do
      rating = rating_fixture()
      assert {:ok, %Rating{}} = Submissions.delete_rating(rating)
      assert_raise Ecto.NoResultsError, fn -> Submissions.get_rating!(rating.id) end
    end

    test "change_rating/1 returns a rating changeset" do
      rating = rating_fixture()
      assert %Ecto.Changeset{} = Submissions.change_rating(rating)
    end
  end
end
