defmodule App.SubmissionsTest do
  use App.DataCase

  alias App.Submissions
  alias App.Accounts
  alias App.Topics
  alias App.Courses
  alias App.TopicsTest, as: TTest
  alias App.AccountsTest, as: ATest


  setup [:create_topic]

  defp create_topic(_context) do
    topic = TTest.topic_fixture()
    section = App.Courses.get_section!(topic.section_id)
    user_faculty = Accounts.get_user_by!("faculty net id")
    submitter = ATest.user_fixture(%{net_id: "submitter"})
    student = ATest.user_fixture(%{net_id: "student"})
    student2 = ATest.user_fixture(%{net_id: "student2"})
    student_notreg = ATest.user_fixture(%{net_id: "student_notreg"})
    role = role_fixture(%{role: "student"})
    App.Accounts.create_section__role(user_faculty, submitter, section, role)
    App.Accounts.create_section__role(user_faculty, student, section, role)
    App.Accounts.create_section__role(user_faculty, student2, section, role)

    [topic: topic, section: section, user_faculty: user_faculty, submitter: submitter, student: student, student2: student2, student_notreg: student_notreg]
  end

  describe "submissions" do
    alias App.Submissions.Submission

    @valid_attrs %{description: "some description", image_url: "some image_url", slug: "some slug", title: "some title"}
    @update_attrs %{description: "some updated description", image_url: "some updated image_url", slug: "some updated slug", title: "some updated title"}
    @invalid_attrs %{description: nil, image_url: nil, slug: nil, title: nil}

    def role_fixture(attrs \\ %{}) do
      {:ok, current_time} = DateTime.now("Etc/UTC")
      defaults = %{role: "none", valid_from: current_time, valid_to: "2100-01-01T00:00:00Z"}

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
      assert {:error, "unauthorized"} = Submissions.create_submission(user_noauth, topic, @valid_attrs)
    end

    test "create_submission/3 on topic with allow_submissions == false returns error", context do
      submitter = context[:submitter]
      topic = context[:topic]
      user_faculty = context[:user_faculty]
      {:ok, topic} = Topics.update_topic(user_faculty, topic, %{allow_submissions: false})
      assert {:error, "creating submissions not allowed"} = Submissions.create_submission(submitter, topic, @valid_attrs)
    end

    test "create_submission/3 on non-writeable course returns error", context do
      submitter = context[:submitter]
      topic = context[:topic]
      section = Courses.get_section!(topic.section_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      course = Courses.get_course!(section.course_id)
      Courses.update_course(user_faculty, course, %{allow_write: false})
      assert {:error, "course write not allowed"} = Submissions.create_submission(submitter, topic, @valid_attrs)
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

    test "update_submission/3 on topic with allow_submissions == false returns error", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      submitter = context[:submitter]
      topic = context[:topic]
      user_faculty = context[:user_faculty]
      {:ok, topic} = Topics.update_topic(user_faculty, topic, %{allow_submissions: false})
      assert {:error, "updating submissions not allowed"} = Submissions.update_submission(submitter, submission, @update_attrs)
    end

    test "update_submission/3 on non-writeable course returns error", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      submitter = context[:submitter]
      topic = context[:topic]
      section = Courses.get_section!(topic.section_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      course = Courses.get_course!(section.course_id)
      Courses.update_course(user_faculty, course, %{allow_write: false})
      assert {:error, "course write not allowed"} = Submissions.update_submission(submitter, submission, @update_attrs)
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

    test "delete_submission/2 on topic with allow_submissions == false returns error", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      submitter = context[:submitter]
      topic = context[:topic]
      user_faculty = context[:user_faculty]
      {:ok, topic} = Topics.update_topic(user_faculty, topic, %{allow_submissions: false})
      assert {:error, "deleting submissions not allowed"} = Submissions.delete_submission(submitter, submission)
    end

    test "delete_submission/2 on non-writeable course returns error", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      submitter = context[:submitter]
      topic = context[:topic]
      section = Courses.get_section!(topic.section_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      course = Courses.get_course!(section.course_id)
      Courses.update_course(user_faculty, course, %{allow_write: false})
      assert {:error, "course write not allowed"} = Submissions.delete_submission(submitter, submission)
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

    def comment_fixture(user, submission, attrs \\ %{}) do
      params =
        attrs
        |> Enum.into(@valid_attrs)

      {:ok, comment} =
        Submissions.create_comment(user, submission, params)

      comment
    end

    test "list_comments/0 returns all comments", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      comment = comment_fixture(context[:student], submission)

      retrieved_comments = Submissions.list_comments()
      retrieved_comment = List.first(retrieved_comments)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description
      assert retrieved_comment.title == comment.title
    end

    test "get_comment!/1 returns the comment with given id", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      comment = comment_fixture(context[:student], submission)
      retrieved_comment = Submissions.get_comment!(comment.id)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description
      assert retrieved_comment.title == comment.title
    end

    test "create_comment/3 with valid data creates a comment", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])

      assert {:ok, %Comment{} = comment} = Submissions.create_comment(student, submission, @valid_attrs)
      assert comment.description == "some description"
      assert comment.title == "some title"
    end

    test "create_comment/3 with invalid data returns error changeset", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      assert {:error, changeset = comment} = Submissions.create_comment(student, submission, @invalid_attrs)
      assert %{title: ["can't be blank"]} = errors_on(changeset)
      assert %{description: ["can't be blank"]} = errors_on(changeset)
    end

    test "create_comment/3 with unauthorized user returns error", context do
      student_notreg = context[:student_notreg]
      submission = submission_fixture(context[:submitter], context[:topic])
      assert {:error, "unauthorized"} = Submissions.create_comment(student_notreg, submission, @invalid_attrs)
    end

    test "create_comment/3 on non-writeable course returns error", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      topic = Topics.get_topic!(submission.topic_id)
      section = Courses.get_section!(topic.section_id)
      course = Courses.get_course!(section.course_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      Courses.update_course(user_faculty, course, %{allow_write: false})

      assert {:error, "course write not allowed"} = Submissions.create_comment(student, submission, @valid_attrs)
    end

    test "update_comment/3 with valid data updates the comment", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      comment = comment_fixture(student, submission)
      assert {:ok, %Comment{} = comment} = Submissions.update_comment(student, comment, @update_attrs)
      assert comment.description == "some updated description"
      assert comment.title == "some updated title"
    end

    test "update_comment/3 with invalid data returns error changeset", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      comment = comment_fixture(student, submission)
      assert {:error, %Ecto.Changeset{}} = Submissions.update_comment(student, comment, @invalid_attrs)
      retrieved_comment = Submissions.get_comment!(comment.id)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description
      assert retrieved_comment.title == comment.title
    end

    test "update_comment/3 by unauthorized user returns error", context do
      student2 = context[:student2]
      submission = submission_fixture(context[:submitter], context[:topic])
      comment = comment_fixture(context[:student], submission)
      assert {:error, "unauthorized"} = Submissions.update_comment(student2, comment, @invalid_attrs)
      retrieved_comment = Submissions.get_comment!(comment.id)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description
      assert retrieved_comment.title == comment.title
    end

    test "update_comment/3 on non-writeable course updates the comment", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      comment = comment_fixture(student, submission)
      topic = Topics.get_topic!(submission.topic_id)
      section = Courses.get_section!(topic.section_id)
      course = Courses.get_course!(section.course_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      Courses.update_course(user_faculty, course, %{allow_write: false})

      assert {:error, "course write not allowed"} = Submissions.update_comment(student, comment, @update_attrs)
      retrieved_comment = Submissions.get_comment!(comment.id)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description
      assert retrieved_comment.title == comment.title
    end

    test "delete_comment/2 deletes the comment", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      comment = comment_fixture(student, submission)
      assert {:ok, %Comment{}} = Submissions.delete_comment(student, comment)
      assert_raise Ecto.NoResultsError, fn -> Submissions.get_comment!(comment.id) end
    end

    test "delete_comment/2 by unauthorized user returns error", context do
      student2 = context[:student2]
      submission = submission_fixture(context[:submitter], context[:topic])
      comment = comment_fixture(context[:student], submission)
      assert {:error, "unauthorized"} = Submissions.delete_comment(student2, comment)
      retrieved_comment = Submissions.get_comment!(comment.id)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description
      assert retrieved_comment.title == comment.title
    end

    test "delete_comment/2 on non-writeable course returns error", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      comment = comment_fixture(student, submission)
      topic = Topics.get_topic!(submission.topic_id)
      section = Courses.get_section!(topic.section_id)
      course = Courses.get_course!(section.course_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      Courses.update_course(user_faculty, course, %{allow_write: false})

      assert {:error, "course write not allowed"} = Submissions.delete_comment(student, comment)
      retrieved_comment = Submissions.get_comment!(comment.id)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description
      assert retrieved_comment.title == comment.title
    end

    test "change_comment/1 returns a comment changeset", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      comment = comment_fixture(context[:student], submission)
      assert %Ecto.Changeset{} = Submissions.change_comment(comment)
    end
  end

  describe "ratings" do
    alias App.Submissions.Rating

    @valid_attrs %{score: 42}
    @update_attrs %{score: 43}
    @invalid_attrs %{score: nil}

    def rating_fixture(user, submission, attrs \\ %{}) do
      params =
        attrs
        |> Enum.into(@valid_attrs)

      {:ok, rating} =
        Submissions.create_rating(user, submission, params)

      rating
    end

    test "list_ratings/0 returns all ratings", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      rating = rating_fixture(student, submission)
      retrieved_ratings = Submissions.list_ratings()
      retrieved_rating = List.first(retrieved_ratings)
      assert retrieved_rating.id == rating.id
      assert retrieved_rating.score == rating.score
    end

    test "get_rating!/1 returns the rating with given id", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      rating = rating_fixture(student, submission)
      retrieved_rating = Submissions.get_rating!(rating.id)
      assert retrieved_rating.id == rating.id
      assert retrieved_rating.score == rating.score
    end

    test "create_rating/3 with valid data creates a rating", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      assert {:ok, %Rating{} = rating} = Submissions.create_rating(student, submission, @valid_attrs)
      assert rating.score == 42
    end

    test "create_rating/3 with invalid data returns error changeset", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      assert {:error, changeset = rating} = Submissions.create_rating(student, submission, @invalid_attrs)
      assert %{score: ["can't be blank"]} = errors_on(changeset)
    end

    test "create_rating/3 by unauthorized user returns error", context do
      student_notreg = context[:student_notreg]
      submission = submission_fixture(context[:submitter], context[:topic])
      assert {:error, "unauthorized"} = Submissions.create_rating(student_notreg, submission, @valid_attrs)
    end

    test "create_rating/3 on non-writeable course returns error", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      topic = Topics.get_topic!(submission.topic_id)
      section = Courses.get_section!(topic.section_id)
      course = Courses.get_course!(section.course_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      Courses.update_course(user_faculty, course, %{allow_write: false})

      assert {:error, "course write not allowed"} = Submissions.create_rating(student, submission, @valid_attrs)
    end

    test "update_rating/3 with valid data updates the rating", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      rating = rating_fixture(student, submission)
      assert {:ok, %Rating{} = rating} = Submissions.update_rating(student, rating, @update_attrs)
      assert rating.score == 43
    end

    test "update_rating/3 with invalid data returns error changeset", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      rating = rating_fixture(student, submission)
      assert {:error, %Ecto.Changeset{}} = Submissions.update_rating(student, rating, @invalid_attrs)
      retrieved_rating = Submissions.get_rating!(rating.id)
      assert retrieved_rating.id == rating.id
      assert retrieved_rating.score == rating.score
    end

    test "update_rating/3 by unauthorized user returns error", context do
      student = context[:student]
      student_notreg = context[:student_notreg]
      submission = submission_fixture(context[:submitter], context[:topic])
      rating = rating_fixture(student, submission)
      assert {:error, "unauthorized"} = Submissions.update_rating(student_notreg, rating, @invalid_attrs)
      retrieved_rating = Submissions.get_rating!(rating.id)
      assert retrieved_rating.id == rating.id
      assert retrieved_rating.score == rating.score
    end

    test "update_rating/3 on non-writeable course returns error", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      rating = rating_fixture(student, submission)
      topic = Topics.get_topic!(submission.topic_id)
      section = Courses.get_section!(topic.section_id)
      course = Courses.get_course!(section.course_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      Courses.update_course(user_faculty, course, %{allow_write: false})

      assert {:error, "course write not allowed"} = Submissions.update_rating(student, rating, @update_attrs)
      retrieved_rating = Submissions.get_rating!(rating.id)
      assert retrieved_rating.id == rating.id
      assert retrieved_rating.score == rating.score
    end

    test "delete_rating/2 deletes the rating", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      rating = rating_fixture(student, submission)
      assert {:ok, %Rating{}} = Submissions.delete_rating(student, rating)
      assert_raise Ecto.NoResultsError, fn -> Submissions.get_rating!(rating.id) end
    end

    test "delete_rating/2 by unauthorized user returns error", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      rating = rating_fixture(student, submission)
      student_notreg = context[:student_notreg]
      assert {:error, "unauthorized"} = Submissions.delete_rating(student_notreg, rating)
    end

    test "delete_rating/2 on non-writeable course returns error", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      rating = rating_fixture(student, submission)
      topic = Topics.get_topic!(submission.topic_id)
      section = Courses.get_section!(topic.section_id)
      course = Courses.get_course!(section.course_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      Courses.update_course(user_faculty, course, %{allow_write: false})

      assert {:error, "course write not allowed"} = Submissions.delete_rating(student, rating)
      retrieved_rating = Submissions.get_rating!(rating.id)
      assert retrieved_rating.id == rating.id
      assert retrieved_rating.score == rating.score
    end


    test "change_rating/1 returns a rating changeset", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      rating = rating_fixture(student, submission)
      assert %Ecto.Changeset{} = Submissions.change_rating(rating)
    end
  end
end
