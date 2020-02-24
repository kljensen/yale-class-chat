defmodule App.CoursesTest do
  use App.DataCase

  alias App.Courses
  alias App.Accounts
  alias App.AccountsTest, as: ATest

  describe "semesters" do
    alias App.Courses.Semester

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def semester_fixture(attrs \\ %{}) do
      params = 
        attrs
        |> Enum.into(@valid_attrs)

      user_faculty = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id (semester)"})

      {:ok, semester} =
        Courses.create_semester(user_faculty, params)

      semester
    end

    test "list_semesters/0 returns all semesters" do
      semester = semester_fixture()
      assert Courses.list_semesters() == [semester]
    end

    test "get_semester!/1 returns the semester with given id" do
      semester = semester_fixture()
      assert Courses.get_semester!(semester.id) == semester
    end

    test "create_semester/2 with valid data creates a semester" do
      user_faculty = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id"})
      assert {:ok, %Semester{} = semester} = Courses.create_semester(user_faculty, @valid_attrs)
      assert semester.name == "some name"
      assert {:error, changeset = semester} = Courses.create_semester(user_faculty, @valid_attrs)
      assert %{name: ["has already been taken"]} = errors_on(changeset)
    end

    test "create_semester/2 with invalid data returns error changeset" do
      user_faculty = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id"})
      assert {:error, changeset = semester} = Courses.create_semester(user_faculty, @invalid_attrs)
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "create_semester/2 by non-faculty user returns error" do
      user_noauth = ATest.user_fixture()
      assert {:error, "unauthorized"} = Courses.create_semester(user_noauth, @valid_attrs)
    end

    test "update_semester/3 with valid data updates the semester" do
      semester = semester_fixture()
      user_faculty = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id"})
      assert {:ok, %Semester{} = semester} = Courses.update_semester(user_faculty, semester, @update_attrs)
      assert semester.name == "some updated name"
    end

    test "update_semester/3 with invalid data returns error changeset" do
      semester = semester_fixture()
      user_faculty = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id"})
      assert {:error, %Ecto.Changeset{}} = Courses.update_semester(user_faculty, semester, @invalid_attrs)
      assert semester == Courses.get_semester!(semester.id)
    end
    
    test "update_semester/3 by unauthorized user returns error" do
      semester = semester_fixture()
      user_noauth = ATest.user_fixture()
      assert {:error, "unauthorized"} = Courses.update_semester(user_noauth, semester, @invalid_attrs)
      assert semester == Courses.get_semester!(semester.id)
    end

    test "delete_semester/2 deletes the semester" do
      semester = semester_fixture()
      user_faculty = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id"})
      assert {:ok, %Semester{}} = Courses.delete_semester(user_faculty, semester)
      assert_raise Ecto.NoResultsError, fn -> Courses.get_semester!(semester.id) end
    end

    test "delete_semester/2 by unauthorized user returns error" do
      semester = semester_fixture()
      user_noauth = ATest.user_fixture()
      assert {:error, "unauthorized"} = Courses.delete_semester(user_noauth, semester)
      assert semester == Courses.get_semester!(semester.id)
    end

    test "change_semester/1 returns a semester changeset" do
      semester = semester_fixture()
      assert %Ecto.Changeset{} = Courses.change_semester(semester)
    end
  end

  describe "courses" do
    alias App.Courses.Course

    @valid_attrs %{department: "some department", name: "some name", number: 42}
    @update_attrs %{department: "some updated department", name: "some updated name", number: 43}
    @invalid_attrs %{department: nil, name: nil, number: nil}

    def course_fixture(attrs \\ %{}) do
      params =
        attrs
        |> Enum.into(@valid_attrs)

      semester = semester_fixture()

      user_faculty = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id"})

      {:ok, course} =
        Courses.create_course(user_faculty, semester, params)

      course
    end

    test "list_courses/0 returns all courses" do
      course = course_fixture()
      course_list = Courses.list_courses()
      retrieved_course = List.first(course_list)
      assert course.id == retrieved_course.id

    end

    test "get_course!/1 returns the course with given id" do
      course = course_fixture()
      assert Courses.get_course!(course.id) == course
    end

    test "create_course/3 with valid data creates a course" do
      semester = semester_fixture()
      user_faculty = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id"})
      assert {:ok, %Course{} = course} = Courses.create_course(user_faculty, semester, @valid_attrs)
      assert course.department == "some department"
      assert course.name == "some name"
      assert course.number == 42
    end

    test "create_course/3 with non-faculty user fails to create a course" do
      semester = semester_fixture()
      user_faculty = ATest.user_fixture(%{is_faculty: false, net_id: "student net id"})
      assert {:error, "unauthorized"} = Courses.create_course(user_faculty, semester, @valid_attrs)
    end

    test "create_course/3 with invalid data returns error changeset" do
      semester = semester_fixture()
      user_faculty = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id"})
      assert {:error, changeset = course} = Courses.create_course(user_faculty, semester, @invalid_attrs)
      assert %{department: ["can't be blank"]} = errors_on(changeset)
      assert %{name: ["can't be blank"]} = errors_on(changeset)
      assert %{number: ["can't be blank"]} = errors_on(changeset)
    end

    test "update_course/3 with valid data updates the course" do
      course = course_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")

      assert {:ok, %Course{} = course} = Courses.update_course(user_faculty, course, @update_attrs)
      assert course.department == "some updated department"
      assert course.name == "some updated name"
      assert course.number == 43
    end

    test "update_course/3 by unauthorized user returns error" do
      course = course_fixture()
      user_noauth = ATest.user_fixture()

      assert {:error, "unauthorized"} = Courses.update_course(user_noauth, course, @update_attrs)
    end

    test "update_course/3 with invalid data returns error changeset" do
      course = course_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")

      assert {:error, %Ecto.Changeset{}} = Courses.update_course(user_faculty, course, @invalid_attrs)
      assert course == Courses.get_course!(course.id)
    end

    test "delete_course/1 deletes the course" do
      course = course_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")

      assert {:ok, %Course{}} = Courses.delete_course(user_faculty, course)
      assert_raise Ecto.NoResultsError, fn -> Courses.get_course!(course.id) end
    end

    test "delete_course/1 by unautorized user returns error" do
      course = course_fixture()
      user_noauth = ATest.user_fixture()

      assert {:error, "unauthorized"} = Courses.delete_course(user_noauth, course)
      assert course == Courses.get_course!(course.id)
    end

    test "change_course/1 returns a course changeset" do
      course = course_fixture()
      assert %Ecto.Changeset{} = Courses.change_course(course)
    end
  end

  describe "sections" do
    alias App.Courses.Section

    @valid_attrs %{crn: "some crn", title: "some title"}
    @update_attrs %{crn: "some updated crn", title: "some updated title"}
    @invalid_attrs %{crn: nil, title: nil}

    def section_fixture(attrs \\ %{}) do
      params =
        attrs
        |> Enum.into(@valid_attrs)

      course = course_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")

      {:ok, section} =
        Courses.create_section(user_faculty, course, params)

      section
    end

    test "list_sections/0 returns all sections" do
      section = section_fixture()
      assert Courses.list_sections() == [section]
    end

    test "get_section!/1 returns the section with given id" do
      section = section_fixture()
      assert Courses.get_section!(section.id) == section
    end

    test "create_section/2 with valid data creates a section" do
      course = course_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")

      assert {:ok, %Section{} = section} = Courses.create_section(user_faculty, course, @valid_attrs)
      assert section.crn == "some crn"
      assert section.title == "some title"
      assert {:error, changeset = section} = Courses.create_section(user_faculty, course, @valid_attrs)
      assert %{crn: ["has already been taken"]} = errors_on(changeset)
    end

    test "create_section/2 with invalid data returns error changeset" do
      course = course_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")

      assert {:error, %Ecto.Changeset{}} = Courses.create_section(user_faculty, course, @invalid_attrs)
    end

    test "create_section/2 as unauthorized user returns error" do
      course = course_fixture()
      user_noauth = ATest.user_fixture()

      assert {:error, "unauthorized"} = Courses.create_section(user_noauth, course, @invalid_attrs)
    end

    test "update_section/2 with valid data updates the section" do
      section = section_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")

      assert {:ok, %Section{} = section} = Courses.update_section(user_faculty, section, @update_attrs)
      assert section.crn == "some updated crn"
      assert section.title == "some updated title"
    end

    test "update_section/2 with invalid data returns error changeset" do
      section = section_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")

      assert {:error, %Ecto.Changeset{}} = Courses.update_section(user_faculty, section, @invalid_attrs)
      assert section == Courses.get_section!(section.id)
    end

    test "update_section/2 by unauthorized user returns error" do
      section = section_fixture()
      user_noauth = ATest.user_fixture()

      assert {:error, "unauthorized"} = Courses.update_section(user_noauth, section, @invalid_attrs)
    end

    test "delete_section/1 deletes the section" do
      section = section_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      
      assert {:ok, %Section{}} = Courses.delete_section(user_faculty, section)
      assert_raise Ecto.NoResultsError, fn -> Courses.get_section!(section.id) end
    end

    test "delete_section/1 by unauthorized user returns error" do
      section = section_fixture()
      user_noauth = ATest.user_fixture()
      
      assert {:error, "unauthorized"} = Courses.delete_section(user_noauth, section)
      assert section == Courses.get_section!(section.id)
    end

    test "change_section/1 returns a section changeset" do
      section = section_fixture()
      assert %Ecto.Changeset{} = Courses.change_section(section)
    end
  end
end
