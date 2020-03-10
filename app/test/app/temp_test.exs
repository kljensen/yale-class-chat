defmodule App.TempTest do
  use App.DataCase

  alias App.Topics
  alias App.Accounts
  alias App.Courses
  alias App.AccountsTest, as: ATest
  alias App.CoursesTest, as: CTest
  alias App.TopicsTest, as: TTest
  alias App.SubmissionsTest, as: STest

  describe "course_role" do
    test "equals section role" do
      section = CTest.section_fixture()
      course = List.first(Courses.list_courses())
      user_faculty = Accounts.get_user_by!("faculty net id")
      assert Accounts.get_current_course__role(user_faculty, course) == Accounts.get_current_course__role(user_faculty, section)
    end

    test "equals topic role" do
      topic = TTest.topic_fixture()
      course = List.first(Courses.list_courses())
      user_faculty = Accounts.get_user_by!("faculty net id")
      assert Accounts.get_current_course__role(user_faculty, course) == Accounts.get_current_course__role(user_faculty, topic)
    end

    test "equals submission role" do
      topic = TTest.topic_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      submission = STest.submission_fixture(user_faculty, topic)
      course = List.first(Courses.list_courses())
      assert Accounts.get_current_course__role(user_faculty, course) == Accounts.get_current_course__role(user_faculty, submission)
    end

    test "equals comment role" do
      topic = TTest.topic_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      submission = STest.submission_fixture(user_faculty, topic)
      comment = STest.comment_fixture(user_faculty, submission)
      course = List.first(Courses.list_courses())
      assert Accounts.get_current_course__role(user_faculty, course) == Accounts.get_current_course__role(user_faculty, comment)
    end

    test "equals rating role" do
      topic = TTest.topic_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      submission = STest.submission_fixture(user_faculty, topic)
      rating = STest.rating_fixture(user_faculty, submission)
      course = List.first(Courses.list_courses())
      assert Accounts.get_current_course__role(user_faculty, course) == Accounts.get_current_course__role(user_faculty, rating)
    end
  end
end
