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
    {:ok, submitter_role} = App.Accounts.create_section__role(user_faculty, submitter, section, role)
    {:ok, student_role} = App.Accounts.create_section__role(user_faculty, student, section, role)
    {:ok, student2_role} = App.Accounts.create_section__role(user_faculty, student2, section, role)

    [topic: topic, section: section, user_faculty: user_faculty, submitter: submitter, student: student, student2: student2, student_notreg: student_notreg, submitter_role: submitter_role, student_role: student_role, student2_role: student2_role]
  end

  describe "submissions" do
    alias App.Submissions.Submission

    @valid_attrs %{description: "some description", image_url: "http://i.imgur.com/u3vyMCW.jpg", slug: "some slug", title: "some title", allow_ranking: true, visible: true}
    @update_attrs %{description: "some updated description", image_url: "http://i.imgur.com/zF7rPAf.jpg", slug: "some updated slug", title: "some updated title", allow_ranking: false, visible: false}
    @invalid_attrs %{description: nil, image_url: nil, slug: nil, title: nil, allow_ranking: nil, hidden: nil}

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

    test "list_submissions/1 returns all submissions for the given topic", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      {:ok, topic2} = App.Topics.create_topic(context[:user_faculty], context[:section], %{allow_submission_comments: true, allow_submission_voting: true, allow_submissions: true, anonymous: true, closed_at: "2100-04-17T14:00:00Z", description: "some other description", opened_at: "2010-04-17T14:00:00Z", slug: "some other slug", sort: "some other sort", title: "some other title", user_submission_limit: 42})
      retrieved_submissions = Submissions.list_submissions(topic2)
      assert length(retrieved_submissions) == 0
      retrieved_submissions = Submissions.list_submissions(context[:topic])
      assert length(retrieved_submissions) == 1
      retrieved_submission = List.first(retrieved_submissions)
      assert retrieved_submission.id == submission.id
      assert retrieved_submission.description == submission.description
      assert retrieved_submission.image_url == submission.image_url
      assert retrieved_submission.slug == submission.slug
      assert retrieved_submission.title == submission.title
    end

    test "list_user_submissions/1 returns user-visible submissions for the given topic", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      student = context[:student]

      retrieved_submissions = Submissions.list_user_submissions(student, context[:topic])
      assert length(retrieved_submissions) == 1

      retrieved_submission = List.first(retrieved_submissions)
      assert retrieved_submission.id == submission.id
      assert retrieved_submission.description == submission.description
      assert retrieved_submission.image_url == submission.image_url
      assert retrieved_submission.slug == submission.slug
      assert retrieved_submission.title == submission.title
    end

    test "list_user_submissions/1 returns no submissions for invalid roles", context do
      submission_fixture(context[:submitter], context[:topic])
      student = context[:student]
      student2 = context[:student]
      student_notreg = context[:student_notreg]
      user_faculty = context[:user_faculty]

      retrieved_submissions = Submissions.list_user_submissions(student, context[:topic])
      assert length(retrieved_submissions) == 1
      retrieved_submissions = Submissions.list_user_submissions(student2, context[:topic])
      assert length(retrieved_submissions) == 1

      retrieved_submissions = Submissions.list_user_submissions(student_notreg, context[:topic])
      assert length(retrieved_submissions) == 0

      {:ok, current_time} = DateTime.now("Etc/UTC")
      params = %{role: "student", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, -7200, :second)}
      App.Accounts.update_section__role(user_faculty, context[:student_role], params)
      params = %{role: "student", valid_from: DateTime.add(current_time, 7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      App.Accounts.update_section__role(user_faculty, context[:student2_role], params)

      retrieved_submissions = Submissions.list_user_submissions(student, context[:topic])
      assert length(retrieved_submissions) == 0
      retrieved_submissions = Submissions.list_user_submissions(student2, context[:topic])
      assert length(retrieved_submissions) == 0
    end

    test "list_user_submissions/1 returns no hidden submissions for the given topic", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      student = context[:student]
      user_faculty = context[:user_faculty]
      topic = context[:topic]

      {:ok, topic} = App.Topics.update_topic(user_faculty, topic, %{show_user_submissions: false})

      retrieved_submissions = Submissions.list_user_submissions(student, context[:topic])
      assert length(retrieved_submissions) == 0

      {:ok, topic} = App.Topics.update_topic(user_faculty, topic, %{show_user_submissions: true})
      retrieved_submissions = Submissions.list_user_submissions(student, topic)
      assert length(retrieved_submissions) == 1

      Submissions.update_submission(user_faculty, submission, %{visible: false})
      retrieved_submissions = Submissions.list_user_submissions(student, topic)
      assert length(retrieved_submissions) == 0
    end

    test "list_user_submissions/1 respects topic sort", context do
      submitter = context[:submitter]
      student1 = context[:student]
      student2 = context[:student2]
      user_faculty = context[:user_faculty]
      topic = context[:topic]

      submission1 = submission_fixture(submitter, topic)
      submission2 = submission_fixture(submitter, topic)

      #Submit ratings for sort
      Submissions.create_rating(student1, submission1, %{score: 1})
      Submissions.create_rating(student2, submission1, %{score: 2})
      Submissions.create_rating(student1, submission2, %{score: 4})
      Submissions.create_rating(student2, submission2, %{score: 5})

      #Sort by date - ascending
      {:ok, topic} = App.Topics.update_topic(user_faculty, topic, %{sort: "date - ascending"})
      submission_list = Submissions.list_user_submissions(user_faculty, topic)
      student_submission_list = Submissions.list_user_submissions(student1, topic)
      assert length(submission_list) == 2
      assert length(student_submission_list) == 2
      assert List.first(submission_list).id == submission1.id
      assert List.last(submission_list).id == submission2.id
      assert List.first(student_submission_list).id == submission1.id
      assert List.last(student_submission_list).id == submission2.id

      #Sort by date - descending
      {:ok, topic} = App.Topics.update_topic(user_faculty, topic, %{sort: "date - descending"})
      submission_list = Submissions.list_user_submissions(user_faculty, topic)
      student_submission_list = Submissions.list_user_submissions(student1, topic)
      assert length(submission_list) == 2
      assert length(student_submission_list) == 2
      assert List.first(submission_list).id == submission2.id
      assert List.last(submission_list).id == submission1.id
      assert List.first(student_submission_list).id == submission2.id
      assert List.last(student_submission_list).id == submission1.id

      #Sort by rating - ascending
      {:ok, topic} = App.Topics.update_topic(user_faculty, topic, %{sort: "rating - ascending"})
      submission_list = Submissions.list_user_submissions(user_faculty, topic)
      student_submission_list = Submissions.list_user_submissions(student1, topic)
      assert length(submission_list) == 2
      assert length(student_submission_list) == 2
      assert List.first(submission_list).id == submission1.id
      assert List.last(submission_list).id == submission2.id
      assert List.first(student_submission_list).id == submission1.id
      assert List.last(student_submission_list).id == submission2.id

      #Sort by rating - ascending
      {:ok, topic} = App.Topics.update_topic(user_faculty, topic, %{sort: "rating - descending"})
      submission_list = Submissions.list_user_submissions(user_faculty, topic)
      student_submission_list = Submissions.list_user_submissions(student1, topic)
      assert length(submission_list) == 2
      assert length(student_submission_list) == 2
      assert List.first(submission_list).id == submission2.id
      assert List.last(submission_list).id == submission1.id
      assert List.first(student_submission_list).id == submission2.id
      assert List.last(student_submission_list).id == submission1.id
    end

    test "list_user_own_submissions/1 returns all submissions by the given user", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      submission2 = submission_fixture(context[:student], context[:topic], %{slug: "student slug"})
      retrieved_submissions = Submissions.list_user_own_submissions(context[:submitter])
      assert length(retrieved_submissions) == 1
      retrieved_submission = List.first(retrieved_submissions)
      assert retrieved_submission.id == submission.id
      assert retrieved_submission.description == submission.description
      assert retrieved_submission.image_url == submission.image_url
      assert retrieved_submission.slug == submission.slug
      assert retrieved_submission.title == submission.title
      retrieved_submissions = Submissions.list_user_own_submissions(context[:student])
      assert length(retrieved_submissions) == 1
      retrieved_submission = List.first(retrieved_submissions)
      assert retrieved_submission.id == submission2.id
      assert retrieved_submission.description == submission2.description
      assert retrieved_submission.image_url == submission2.image_url
      assert retrieved_submission.slug == submission2.slug
      assert retrieved_submission.title == submission2.title
    end

    test "list_user_own_submissions/2 returns all submissions by the given user for the given topic", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      submission2 = submission_fixture(context[:student], context[:topic], %{slug: "student slug"})
      {:ok, topic2} = App.Topics.create_topic(context[:user_faculty], context[:section], %{allow_submission_comments: true, allow_submission_voting: true, allow_submissions: true, anonymous: true, closed_at: "2100-04-17T14:00:00Z", description: "some other description", opened_at: "2010-04-17T14:00:00Z", slug: "some other slug", sort: "some other sort", title: "some other title", user_submission_limit: 42})
      retrieved_submissions = Submissions.list_user_own_submissions(context[:submitter], topic2)
      assert length(retrieved_submissions) == 0
      retrieved_submissions = Submissions.list_user_own_submissions(context[:student], topic2)
      assert length(retrieved_submissions) == 0
      retrieved_submissions = Submissions.list_user_own_submissions(context[:submitter], context[:topic])
      assert length(retrieved_submissions) == 1
      retrieved_submission = List.first(retrieved_submissions)
      assert retrieved_submission.id == submission.id
      assert retrieved_submission.description == submission.description
      assert retrieved_submission.image_url == submission.image_url
      assert retrieved_submission.slug == submission.slug
      assert retrieved_submission.title == submission.title
      retrieved_submissions = Submissions.list_user_own_submissions(context[:student], context[:topic])
      assert length(retrieved_submissions) == 1
      retrieved_submission = List.first(retrieved_submissions)
      assert retrieved_submission.id == submission2.id
      assert retrieved_submission.description == submission2.description
      assert retrieved_submission.image_url == submission2.image_url
      assert retrieved_submission.slug == submission2.slug
      assert retrieved_submission.title == submission2.title
    end

    test "count_user_submissions/2 returns count of all submissions by the given user for the given topic", context do
      submission_fixture(context[:submitter], context[:topic])
      submission_fixture(context[:student], context[:topic], %{slug: "student slug"})
      {:ok, topic2} = App.Topics.create_topic(context[:user_faculty], context[:section], %{allow_submission_comments: true, allow_submission_voting: true, allow_submissions: true, anonymous: true, closed_at: "2100-04-17T14:00:00Z", description: "some other description", opened_at: "2010-04-17T14:00:00Z", slug: "some other slug", sort: "some other sort", title: "some other title", user_submission_limit: 42})
      assert Submissions.count_user_submissions(context[:submitter], topic2) == [0]
      assert Submissions.count_user_submissions(context[:student], topic2) == [0]
      assert Submissions.count_user_submissions(context[:submitter], context[:topic]) == [1]
      assert Submissions.count_user_submissions(context[:student], context[:topic]) == [1]
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
      assert submission.image_url == "http://i.imgur.com/u3vyMCW.jpg"
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

    test "create_submission/3 returns error if topic not yet open", context do
      submitter = context[:submitter]
      topic = context[:topic]
      user_faculty = context[:user_faculty]
      {:ok, topic} = Topics.update_topic(user_faculty, topic, %{opened_at: "2100-04-17T14:00:00Z"})
      assert {:error, "topic not yet open"} = Submissions.create_submission(submitter, topic, @valid_attrs)
    end

    test "create_submission/3 returns error if topic closed", context do
      submitter = context[:submitter]
      topic = context[:topic]
      user_faculty = context[:user_faculty]
      {:ok, topic} = Topics.update_topic(user_faculty, topic, %{closed_at: "2010-04-17T14:00:00Z"})
      assert {:error, "topic closed"} = Submissions.create_submission(submitter, topic, @valid_attrs)
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

    test "create_submission/3 returns error if user submisssion limit reached", context do
      submitter = context[:submitter]
      topic = context[:topic]
      user_faculty = context[:user_faculty]
      {:ok, topic} = Topics.update_topic(user_faculty, topic, %{user_submission_limit: 0})
      assert {:error, "user submission limit reached"} = Submissions.create_submission(submitter, topic, @valid_attrs)
    end

    test "update_submission/3 with valid data updates the submission", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      submitter = context[:submitter]
      assert {:ok, %Submission{} = submission} = Submissions.update_submission(submitter, submission, @update_attrs)
      assert submission.description == "some updated description"
      assert submission.image_url == "http://i.imgur.com/zF7rPAf.jpg"
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
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{allow_submissions: false})
      assert {:error, "updating submissions not allowed"} = Submissions.update_submission(submitter, submission, @update_attrs)
    end

    test "update_submission/3 returns error if topic not yet open", context do
      submitter = context[:submitter]
      topic = context[:topic]
      submission = submission_fixture(submitter, topic)
      user_faculty = context[:user_faculty]
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{opened_at: "2100-04-17T14:00:00Z"})
      assert {:error, "topic not yet open"} = Submissions.update_submission(submitter, submission, @update_attrs)
      retrieved_submission = Submissions.get_submission!(submission.id)
      assert retrieved_submission.id == submission.id
      assert retrieved_submission.description == submission.description
      assert retrieved_submission.image_url == submission.image_url
      assert retrieved_submission.slug == submission.slug
      assert retrieved_submission.title == submission.title
    end

    test "update_submission/3 returns error if topic closed", context do
      submitter = context[:submitter]
      topic = context[:topic]
      user_faculty = context[:user_faculty]
      submission = submission_fixture(submitter, topic)
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{closed_at: "2010-04-17T14:00:00Z"})
      assert {:error, "topic closed"} = Submissions.update_submission(submitter, submission, @update_attrs)
      retrieved_submission = Submissions.get_submission!(submission.id)
      assert retrieved_submission.id == submission.id
      assert retrieved_submission.description == submission.description
      assert retrieved_submission.image_url == submission.image_url
      assert retrieved_submission.slug == submission.slug
      assert retrieved_submission.title == submission.title
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
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{allow_submissions: false})
      assert {:error, "deleting submissions not allowed"} = Submissions.delete_submission(submitter, submission)
    end

    test "delete_submission/2 returns error if topic not yet open", context do
      submitter = context[:submitter]
      topic = context[:topic]
      submission = submission_fixture(submitter, topic)
      user_faculty = context[:user_faculty]
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{opened_at: "2100-04-17T14:00:00Z"})
      assert {:error, "topic not yet open"} = Submissions.delete_submission(submitter, submission)
      retrieved_submission = Submissions.get_submission!(submission.id)
      assert retrieved_submission.id == submission.id
      assert retrieved_submission.description == submission.description
      assert retrieved_submission.image_url == submission.image_url
      assert retrieved_submission.slug == submission.slug
      assert retrieved_submission.title == submission.title
    end

    test "delete_submission/2 returns error if topic closed", context do
      submitter = context[:submitter]
      topic = context[:topic]
      user_faculty = context[:user_faculty]
      submission = submission_fixture(submitter, topic)
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{closed_at: "2010-04-17T14:00:00Z"})
      assert {:error, "topic closed"} = Submissions.delete_submission(submitter, submission)
      retrieved_submission = Submissions.get_submission!(submission.id)
      assert retrieved_submission.id == submission.id
      assert retrieved_submission.description == submission.description
      assert retrieved_submission.image_url == submission.image_url
      assert retrieved_submission.slug == submission.slug
      assert retrieved_submission.title == submission.title
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

    @valid_attrs %{description: "some description"}
    @update_attrs %{description: "some updated description"}
    @invalid_attrs %{description: nil}

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
    end

    test "list_comments/1 returns all comments for the given submission", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      submission2 = submission_fixture(context[:submitter], context[:topic], %{slug: "some other slug"})
      comment = comment_fixture(context[:student], submission)
      comment2 = comment_fixture(context[:student], submission2)

      retrieved_comments = Submissions.list_comments(submission2)
      assert length(retrieved_comments) == 1
      retrieved_comment = List.first(retrieved_comments)
      assert retrieved_comment.id == comment2.id
      assert retrieved_comment.description == comment2.description
      retrieved_comments = Submissions.list_comments(submission)
      assert length(retrieved_comments) == 1
      retrieved_comment = List.first(retrieved_comments)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description
    end

    test "list_user_comments/3 returns all comments for the given submission", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      submission2 = submission_fixture(context[:submitter], context[:topic], %{slug: "some other slug"})
      comment = comment_fixture(context[:student], submission)
      user_faculty = Accounts.get_user_by!("faculty net id")
      student = context[:student]

      retrieved_comments = Submissions.list_user_comments(student, submission2)
      assert length(retrieved_comments) == 0
      retrieved_comments = Submissions.list_user_comments(student, submission)
      assert length(retrieved_comments) == 1
      retrieved_comment = List.first(retrieved_comments)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description

      retrieved_comments = Submissions.list_user_comments(user_faculty, submission2)
      assert length(retrieved_comments) == 0
      retrieved_comments = Submissions.list_user_comments(user_faculty, submission)
      assert length(retrieved_comments) == 1
      retrieved_comment = List.first(retrieved_comments)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description
    end

    test "list_user_comments/3 returns no comments if no valid role", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      comment_fixture(context[:student], submission)
      user_faculty = Accounts.get_user_by!("faculty net id")
      user_faculty2 = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id 2"})
      student = context[:student]
      course = Courses.get_course!(context[:section].course_id)
      {:ok, current_time} = DateTime.now("Etc/UTC")

      params = %{role: "administrator", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, -7200, :second)}
      {:ok, course_role} = Accounts.create_course__role(user_faculty, user_faculty2, course, params)
      params = %{role: "student", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, -7200, :second)}
      Accounts.update_section__role(user_faculty, context[:student_role], params)

      retrieved_comments = Submissions.list_user_comments(student, submission)
      assert length(retrieved_comments) == 0
      retrieved_comments = Submissions.list_user_comments(user_faculty2, submission)
      assert length(retrieved_comments) == 0

      params = %{role: "administrator", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      {:ok, course_role} = Accounts.update_course__role(user_faculty, course_role, params)
      params = %{role: "student", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      Accounts.update_section__role(user_faculty, context[:student_role], params)

      retrieved_comments = Submissions.list_user_comments(student, submission)
      assert length(retrieved_comments) == 1
      retrieved_comments = Submissions.list_user_comments(user_faculty2, submission)
      assert length(retrieved_comments) == 1

      params = %{role: "administrator", valid_from: DateTime.add(current_time, 7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      Accounts.update_course__role(user_faculty, course_role, params)
      params = %{role: "student", valid_from: DateTime.add(current_time, 7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      Accounts.update_section__role(user_faculty, context[:student_role], params)

      retrieved_comments = Submissions.list_user_comments(student, submission)
      assert length(retrieved_comments) == 0
      retrieved_comments = Submissions.list_user_comments(user_faculty2, submission)
      assert length(retrieved_comments) == 0

    end

    test "list_user_own_comments/1 returns all comments by the given user", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      submission2 = submission_fixture(context[:submitter], context[:topic], %{slug: "some other slug"})
      comment = comment_fixture(context[:student], submission)
      comment2 = comment_fixture(context[:student], submission2)
      student = context[:student]
      student2 = context[:student2]

      retrieved_comments = Submissions.list_user_own_comments(student)
      assert length(retrieved_comments) == 2
      retrieved_comment = List.first(retrieved_comments)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description
      retrieved_comment = List.last(retrieved_comments)
      assert retrieved_comment.id == comment2.id
      assert retrieved_comment.description == comment2.description

      retrieved_comments = Submissions.list_user_own_comments(student2)
      assert length(retrieved_comments) == 0
    end

    test "list_user_own_comments/2 returns all comments by the given user for the given submission", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      submission2 = submission_fixture(context[:submitter], context[:topic], %{slug: "some other slug"})
      comment = comment_fixture(context[:student], submission)
      comment2 = comment_fixture(context[:student], submission2)
      student = context[:student]
      student2 = context[:student2]

      retrieved_comments = Submissions.list_user_own_comments(student, submission)
      assert length(retrieved_comments) == 1
      retrieved_comment = List.first(retrieved_comments)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description

      retrieved_comments = Submissions.list_user_own_comments(student, submission2)
      assert length(retrieved_comments) == 1
      retrieved_comment = List.first(retrieved_comments)
      assert retrieved_comment.id == comment2.id
      assert retrieved_comment.description == comment2.description

      retrieved_comments = Submissions.list_user_own_comments(student2, submission)
      assert length(retrieved_comments) == 0
      retrieved_comments = Submissions.list_user_own_comments(student2, submission2)
      assert length(retrieved_comments) == 0
    end

    test "get_comment!/1 returns the comment with given id", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      comment = comment_fixture(context[:student], submission)
      retrieved_comment = Submissions.get_comment!(comment.id)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description
    end

    test "create_comment/3 with valid data creates a comment", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])

      assert {:ok, %Comment{} = comment} = Submissions.create_comment(student, submission, @valid_attrs)
      assert comment.description == "some description"
    end

    test "create_comment/3 with invalid data returns error changeset", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      assert {:error, changeset = comment} = Submissions.create_comment(student, submission, @invalid_attrs)
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

    test "create_comment/3 returns error if topic not yet open", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      topic = Topics.get_topic!(submission.topic_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{opened_at: "2100-04-17T14:00:00Z"})
      assert {:error, "topic not yet open"} = Submissions.create_comment(student, submission, @valid_attrs)
    end

    test "create_comment/3 returns error if topic closed", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      topic = Topics.get_topic!(submission.topic_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{closed_at: "2010-04-17T14:00:00Z"})
      assert {:error, "topic closed"} = Submissions.create_comment(student, submission, @valid_attrs)
    end

    test "create_comment/3 returns error if commenting not allowed", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      topic = Topics.get_topic!(submission.topic_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{allow_submission_comments: false})
      assert {:error, "commenting not allowed"} = Submissions.create_comment(student, submission, @valid_attrs)
    end

    test "update_comment/3 with valid data updates the comment", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      comment = comment_fixture(student, submission)
      assert {:ok, %Comment{} = comment} = Submissions.update_comment(student, comment, @update_attrs)
      assert comment.description == "some updated description"
    end

    test "update_comment/3 with invalid data returns error changeset", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      comment = comment_fixture(student, submission)
      assert {:error, %Ecto.Changeset{}} = Submissions.update_comment(student, comment, @invalid_attrs)
      retrieved_comment = Submissions.get_comment!(comment.id)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description
    end

    test "update_comment/3 by unauthorized user returns error", context do
      student2 = context[:student2]
      submission = submission_fixture(context[:submitter], context[:topic])
      comment = comment_fixture(context[:student], submission)
      assert {:error, "unauthorized"} = Submissions.update_comment(student2, comment, @invalid_attrs)
      retrieved_comment = Submissions.get_comment!(comment.id)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description
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
    end

    test "update_comment/3 returns error if topic not yet open", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      comment = comment_fixture(student, submission)
      topic = Topics.get_topic!(submission.topic_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{opened_at: "2100-04-17T14:00:00Z"})
      assert {:error, "topic not yet open"} = Submissions.update_comment(student, comment, @update_attrs)
      retrieved_comment = Submissions.get_comment!(comment.id)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description
    end

    test "update_comment/3 returns error if topic closed", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      comment = comment_fixture(student, submission)
      topic = Topics.get_topic!(submission.topic_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{closed_at: "2010-04-17T14:00:00Z"})
      assert {:error, "topic closed"} = Submissions.update_comment(student, comment, @update_attrs)
      retrieved_comment = Submissions.get_comment!(comment.id)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description
    end

    test "update_comment/3 returns error if commenting not allowed", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      comment = comment_fixture(student, submission)
      topic = Topics.get_topic!(submission.topic_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{allow_submission_comments: false})
      assert {:error, "commenting not allowed"} = Submissions.update_comment(student, comment, @update_attrs)
      retrieved_comment = Submissions.get_comment!(comment.id)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description
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
    end

    test "delete_comment/2 returns error if topic not yet open", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      comment = comment_fixture(student, submission)
      topic = Topics.get_topic!(submission.topic_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{opened_at: "2100-04-17T14:00:00Z"})
      assert {:error, "topic not yet open"} = Submissions.delete_comment(student, comment)
      retrieved_comment = Submissions.get_comment!(comment.id)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description
    end

    test "delete_comment/2 returns error if topic closed", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      comment = comment_fixture(student, submission)
      topic = Topics.get_topic!(submission.topic_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{closed_at: "2010-04-17T14:00:00Z"})
      assert {:error, "topic closed"} = Submissions.delete_comment(student, comment)
      retrieved_comment = Submissions.get_comment!(comment.id)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description
    end

    test "delete_comment/2 returns error if commenting not allowed", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      comment = comment_fixture(student, submission)
      topic = Topics.get_topic!(submission.topic_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{allow_submission_comments: false})
      assert {:error, "commenting not allowed"} = Submissions.delete_comment(student, comment)
      retrieved_comment = Submissions.get_comment!(comment.id)
      assert retrieved_comment.id == comment.id
      assert retrieved_comment.description == comment.description
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

    test "list_ratings/1 returns all ratings for the given submission", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      submission2 = submission_fixture(context[:submitter], context[:topic], %{slug: "some other slug"})
      rating = rating_fixture(context[:student], submission)
      rating2 = rating_fixture(context[:student], submission2)

      retrieved_ratings = Submissions.list_ratings(submission2)
      assert length(retrieved_ratings) == 1
      retrieved_rating = List.first(retrieved_ratings)
      assert retrieved_rating.id == rating2.id
      assert retrieved_rating.score == rating2.score
      retrieved_ratings = Submissions.list_ratings(submission)
      assert length(retrieved_ratings) == 1
      retrieved_rating = List.first(retrieved_ratings)
      assert retrieved_rating.id == rating.id
      assert retrieved_rating.score == rating.score
    end

    test "list_user_ratings/3 returns all ratings for the given submission", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      submission2 = submission_fixture(context[:submitter], context[:topic], %{slug: "some other slug"})
      rating = rating_fixture(context[:student], submission)
      user_faculty = Accounts.get_user_by!("faculty net id")
      student = context[:student]

      retrieved_ratings = Submissions.list_user_ratings(student, submission2)
      assert length(retrieved_ratings) == 0
      retrieved_ratings = Submissions.list_user_ratings(student, submission)
      assert length(retrieved_ratings) == 1
      retrieved_rating = List.first(retrieved_ratings)
      assert retrieved_rating.id == rating.id
      assert retrieved_rating.score == rating.score

      retrieved_ratings = Submissions.list_user_ratings(user_faculty, submission2)
      assert length(retrieved_ratings) == 0
      retrieved_ratings = Submissions.list_user_ratings(user_faculty, submission)
      assert length(retrieved_ratings) == 1
      retrieved_rating = List.first(retrieved_ratings)
      assert retrieved_rating.id == rating.id
      assert retrieved_rating.score == rating.score
    end

    test "list_user_ratings/3 returns no ratings if no valid role", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      rating_fixture(context[:student], submission)
      user_faculty = Accounts.get_user_by!("faculty net id")
      user_faculty2 = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id 2"})
      student = context[:student]
      course = Courses.get_course!(context[:section].course_id)
      {:ok, current_time} = DateTime.now("Etc/UTC")

      params = %{role: "administrator", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, -7200, :second)}
      {:ok, course_role} = Accounts.create_course__role(user_faculty, user_faculty2, course, params)
      params = %{role: "student", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, -7200, :second)}
      Accounts.update_section__role(user_faculty, context[:student_role], params)

      retrieved_ratings = Submissions.list_user_ratings(student, submission)
      assert length(retrieved_ratings) == 0
      retrieved_ratings = Submissions.list_user_ratings(user_faculty2, submission)
      assert length(retrieved_ratings) == 0

      params = %{role: "administrator", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      {:ok, course_role} = Accounts.update_course__role(user_faculty, course_role, params)
      params = %{role: "student", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      Accounts.update_section__role(user_faculty, context[:student_role], params)

      retrieved_ratings = Submissions.list_user_ratings(student, submission)
      assert length(retrieved_ratings) == 1
      retrieved_ratings = Submissions.list_user_ratings(user_faculty2, submission)
      assert length(retrieved_ratings) == 1

      params = %{role: "administrator", valid_from: DateTime.add(current_time, 7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      Accounts.update_course__role(user_faculty, course_role, params)
      params = %{role: "student", valid_from: DateTime.add(current_time, 7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      Accounts.update_section__role(user_faculty, context[:student_role], params)

      retrieved_ratings = Submissions.list_user_ratings(student, submission)
      assert length(retrieved_ratings) == 0
      retrieved_ratings = Submissions.list_user_ratings(user_faculty2, submission)
      assert length(retrieved_ratings) == 0

    end

    test "list_user_own_ratings/1 returns all ratings by the given user", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      submission2 = submission_fixture(context[:submitter], context[:topic], %{slug: "some other slug"})
      rating = rating_fixture(context[:student], submission)
      rating2 = rating_fixture(context[:student], submission2)
      student = context[:student]
      student2 = context[:student2]

      retrieved_ratings = Submissions.list_user_own_ratings(student)
      assert length(retrieved_ratings) == 2
      retrieved_rating = List.first(retrieved_ratings)
      assert retrieved_rating.id == rating.id
      assert retrieved_rating.score == rating.score
      retrieved_rating = List.last(retrieved_ratings)
      assert retrieved_rating.id == rating2.id
      assert retrieved_rating.score == rating2.score

      retrieved_ratings = Submissions.list_user_own_ratings(student2)
      assert length(retrieved_ratings) == 0
    end

    test "list_user_own_ratings/2 returns all ratings by the given user for the given submission", context do
      submission = submission_fixture(context[:submitter], context[:topic])
      submission2 = submission_fixture(context[:submitter], context[:topic], %{slug: "some other slug"})
      rating = rating_fixture(context[:student], submission)
      rating2 = rating_fixture(context[:student], submission2)
      student = context[:student]
      student2 = context[:student2]

      retrieved_ratings = Submissions.list_user_own_ratings(student, submission)
      assert length(retrieved_ratings) == 1
      retrieved_rating = List.first(retrieved_ratings)
      assert retrieved_rating.id == rating.id
      assert retrieved_rating.score == rating.score

      retrieved_ratings = Submissions.list_user_own_ratings(student, submission2)
      assert length(retrieved_ratings) == 1
      retrieved_rating = List.first(retrieved_ratings)
      assert retrieved_rating.id == rating2.id
      assert retrieved_rating.score == rating2.score

      retrieved_ratings = Submissions.list_user_own_ratings(student2, submission)
      assert length(retrieved_ratings) == 0
      retrieved_ratings = Submissions.list_user_own_ratings(student2, submission2)
      assert length(retrieved_ratings) == 0
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

    test "create_rating/3 returns error if topic not yet open", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      topic = Topics.get_topic!(submission.topic_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{opened_at: "2100-04-17T14:00:00Z"})
      assert {:error, "topic not yet open"} = Submissions.create_rating(student, submission, @valid_attrs)
    end

    test "create_rating/3 on a closed topic returns error", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      topic = Topics.get_topic!(submission.topic_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{closed_at: "2010-04-17T14:00:00Z"})
      assert {:error, "topic closed"} = Submissions.create_rating(student, submission, @valid_attrs)
    end

    test "create_rating/3 returns error if rating not allowed", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      topic = Topics.get_topic!(submission.topic_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{allow_submission_voting: false})
      assert {:error, "rating not allowed"} = Submissions.create_rating(student, submission, @valid_attrs)
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

    test "update_rating/3 returns error if topic not yet open", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      rating = rating_fixture(student, submission)
      topic = Topics.get_topic!(submission.topic_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{opened_at: "2100-04-17T14:00:00Z"})
      assert {:error, "topic not yet open"} = Submissions.update_rating(student, rating, @update_attrs)
      retrieved_rating = Submissions.get_rating!(rating.id)
      assert retrieved_rating.id == rating.id
      assert retrieved_rating.score == rating.score
    end

    test "update_rating/3 on a closed topic returns error", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      rating = rating_fixture(student, submission)
      topic = Topics.get_topic!(submission.topic_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{closed_at: "2010-04-17T14:00:00Z"})
      assert {:error, "topic closed"} = Submissions.update_rating(student, rating, @update_attrs)
      retrieved_rating = Submissions.get_rating!(rating.id)
      assert retrieved_rating.id == rating.id
      assert retrieved_rating.score == rating.score
    end

    test "update_rating/3 returns error if rating disallowed", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      rating = rating_fixture(student, submission)
      topic = Topics.get_topic!(submission.topic_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{allow_submission_voting: false})
      assert {:error, "rating not allowed"} = Submissions.update_rating(student, rating, @update_attrs)
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

    test "delete_rating/2 returns error if topic not yet open", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      rating = rating_fixture(student, submission)
      topic = Topics.get_topic!(submission.topic_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{opened_at: "2100-04-17T14:00:00Z"})
      assert {:error, "topic not yet open"} = Submissions.delete_rating(student, rating)
      retrieved_rating = Submissions.get_rating!(rating.id)
      assert retrieved_rating.id == rating.id
      assert retrieved_rating.score == rating.score
    end

    test "delete_rating/2 on a closed topic returns error", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      rating = rating_fixture(student, submission)
      topic = Topics.get_topic!(submission.topic_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{closed_at: "2010-04-17T14:00:00Z"})
      assert {:error, "topic closed"} = Submissions.delete_rating(student, rating)
      retrieved_rating = Submissions.get_rating!(rating.id)
      assert retrieved_rating.id == rating.id
      assert retrieved_rating.score == rating.score
    end

    test "delete_rating/2 returns error if rating not allowed", context do
      student = context[:student]
      submission = submission_fixture(context[:submitter], context[:topic])
      rating = rating_fixture(student, submission)
      topic = Topics.get_topic!(submission.topic_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      {:ok, _topic} = Topics.update_topic(user_faculty, topic, %{allow_submission_voting: false})
      assert {:error, "rating not allowed"} = Submissions.delete_rating(student, rating)
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
