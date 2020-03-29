defmodule App.CoursesTest do
  use App.DataCase

  alias App.Courses
  alias App.Accounts
  alias App.AccountsTest, as: ATest

  describe "semesters" do
    alias App.Courses.Semester

    @valid_attrs %{name: "some name", term_code: "202001"}
    @update_attrs %{name: "some updated name", term_code: "202002"}
    @invalid_attrs %{name: nil, term_code: nil}

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
      assert %{term_code: ["can't be blank"]} = errors_on(changeset)
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
      assert semester.term_code == "202002"
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

    @valid_attrs %{department: "some department", name: "some name", number: 42, allow_write: true, allow_read: true}
    @update_attrs %{department: "some updated department", name: "some updated name", number: 43, allow_write: false, allow_read: false}
    @invalid_attrs %{department: nil, name: nil, number: nil, allow_write: nil, allow_read: nil}

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
      assert retrieved_course.department == course.department
      assert retrieved_course.name == course.name
      assert retrieved_course.number == course.number
    end

    test "list_user_courses/1 returns all courses for which a user has a valid user role" do
      course = course_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      user_faculty2 = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id 2"})
      course_list = Courses.list_user_courses(user_faculty)
      assert length(course_list) == 1
      retrieved_course = List.first(course_list)
      assert course.id == retrieved_course.id
      assert retrieved_course.department == course.department
      assert retrieved_course.name == course.name
      assert retrieved_course.number == course.number
      course_list = Courses.list_user_courses(user_faculty2)
      assert length(course_list) == 0
    end

    test "list_courses/1 returns all courses for a given semester" do
      course = course_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      semester = Courses.get_semester!(course.semester_id)
      {:ok, semester2} = Courses.create_semester(user_faculty, %{name: "empty semester", term_code: "190001"})
      course_list = Courses.list_courses(semester)
      retrieved_course = List.first(course_list)
      assert course.id == retrieved_course.id
      assert retrieved_course.department == course.department
      assert retrieved_course.name == course.name
      assert retrieved_course.number == course.number
      course_list = Courses.list_courses(semester2)
      assert length(course_list) == 0
    end

    test "list_user_courses/2 returns all courses in a semester for which a user has a valid course role" do
      course = course_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      semester = Courses.get_semester!(course.semester_id)
      {:ok, semester2} = Courses.create_semester(user_faculty, %{name: "empty semester", term_code: "190001"})
      user_faculty2 = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id 2"})
      course_list = Courses.list_user_courses(semester, user_faculty)
      assert length(course_list) == 1
      retrieved_course = List.first(course_list)
      assert course.id == retrieved_course.id
      assert retrieved_course.department == course.department
      assert retrieved_course.name == course.name
      assert retrieved_course.number == course.number
      course_list = Courses.list_user_courses(semester, user_faculty2)
      assert length(course_list) == 0
      course_list = Courses.list_user_courses(semester2, user_faculty)
      assert length(course_list) == 0
      course_list = Courses.list_user_courses(semester2, user_faculty2)
      assert length(course_list) == 0
    end

    test "list_user_courses/1 returns no courses if user roles expired" do
      course = course_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      user_faculty2 = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id 2"})
      {:ok, current_time} = DateTime.now("Etc/UTC")
      #Expired role returns no courses
      params = %{role: "administrator", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, -7200, :second)}
      {:ok, course_role} = Accounts.create_course__role(user_faculty, user_faculty2, course, params)
      course_list = Courses.list_user_courses(user_faculty2)
      assert length(course_list) == 0
      #Valid role returns one course
      params = %{role: "administrator", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      {:ok, course_role} = Accounts.update_course__role!(user_faculty, course_role, params)
      course_list = Courses.list_user_courses(user_faculty2)
      assert length(course_list) == 1
      #Yet to begin role returns no courses
      params = %{role: "administrator", valid_from: DateTime.add(current_time, 7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      Accounts.update_course__role!(user_faculty, course_role, params)
      course_list = Courses.list_user_courses(user_faculty2)
      assert length(course_list) == 0
    end

    test "list_user_courses/2 returns no courses if course roles expired" do
      course = course_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      user_faculty2 = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id 2"})
      semester = Courses.get_semester!(course.semester_id)
      {:ok, semester2} = Courses.create_semester(user_faculty, %{name: "empty semester", term_code: "190001"})
      {:ok, current_time} = DateTime.now("Etc/UTC")
      #Expired role returns no courses
      params = %{role: "administrator", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, -7200, :second)}
      {:ok, course_role} = Accounts.create_course__role(user_faculty, user_faculty2, course, params)
      course_list = Courses.list_user_courses(semester, user_faculty2)
      assert length(course_list) == 0
      #Valid role returns one course
      params = %{role: "administrator", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      {:ok, course_role} = Accounts.update_course__role!(user_faculty, course_role, params)
      course_list = Courses.list_user_courses(semester, user_faculty2)
      assert length(course_list) == 1
      #Incorrect semester returns no courses
      course_list = Courses.list_user_courses(semester2, user_faculty2)
      assert length(course_list) == 0
      #Yet to begin role returns no courses
      params = %{role: "administrator", valid_from: DateTime.add(current_time, 7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      Accounts.update_course__role!(user_faculty, course_role, params)
      course_list = Courses.list_user_courses(semester, user_faculty2)
      assert length(course_list) == 0
    end

    test "get_course!/1 returns the course with given id" do
      course = course_fixture()
      retrieved_course = Courses.get_course!(course.id)
      assert retrieved_course.id == course.id
      assert retrieved_course.department == course.department
      assert retrieved_course.name == course.name
      assert retrieved_course.number == course.number
    end

    test "get_user_course/1 returns the course with given id if user can view" do
      course = course_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      assert {:ok, retrieved_course} = Courses.get_user_course(user_faculty, course.id)
      assert retrieved_course.id == course.id
      assert retrieved_course.department == course.department
      assert retrieved_course.name == course.name
      assert retrieved_course.number == course.number
    end

    test "get_user_course/1 returns error if user cannot view or course does not exist" do
      course = course_fixture()
      user = ATest.user_fixture(%{is_faculty: false, net_id: "student net id"})
      assert {:error, message} = Courses.get_user_course(user, course.id)
      assert message = "forbidden"
      assert {:error, message} = Courses.get_user_course(user, course.id + 1)
      assert message = "not found"
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

    test "update_course/3 with changed semester changes association" do
      course = course_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      {:ok, semester2} = Courses.create_semester(user_faculty, %{name: "some updated name", term_code: "202002"})

      refute course.semester_id == semester2.id
      assert {:ok, %Course{} = course} = Courses.update_course(user_faculty, course, %{semester_id: semester2.id})
      assert course.semester_id == semester2.id
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
      retrieved_course = Courses.get_course!(course.id)
      assert retrieved_course.id == course.id
      assert retrieved_course.department == course.department
      assert retrieved_course.name == course.name
      assert retrieved_course.number == course.number
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
      retrieved_course = Courses.get_course!(course.id)
      assert retrieved_course.id == course.id
      assert retrieved_course.department == course.department
      assert retrieved_course.name == course.name
      assert retrieved_course.number == course.number
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
      retrieved_sections = Courses.list_sections()
      retrieved_section = List.first(retrieved_sections)
      assert retrieved_section.id == section.id
      assert retrieved_section.crn == section.crn
      assert retrieved_section.title == section.title
    end

    test "list_user_sections/1 returns all sections for which a user has a valid user role" do
      section = section_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      user_student = ATest.user_fixture(%{is_faculty: false, net_id: "student net id"})
      user_student2 = ATest.user_fixture(%{is_faculty: false, net_id: "other student net id"})
      {:ok, current_time} = DateTime.now("Etc/UTC")
      params = %{role: "student", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      Accounts.create_section__role!(user_faculty, user_student, section, params)
      section_list = Courses.list_user_sections(user_student)
      assert length(section_list) == 1
      retrieved_section = List.first(section_list)
      assert retrieved_section.id == section.id
      assert retrieved_section.crn == section.crn
      assert retrieved_section.title == section.title
      section_list = Courses.list_user_sections(user_student2)
      assert length(section_list) == 0
    end

    test "list_user_sections/1 returns all sections for which a user has a valid course role" do
      section = section_fixture()
      course = Courses.get_course!(section.course_id)
      user_faculty = Accounts.get_user_by!("faculty net id")
      user_student = ATest.user_fixture(%{is_faculty: false, net_id: "student net id"})
      user_student2 = ATest.user_fixture(%{is_faculty: false, net_id: "other student net id"})
      {:ok, current_time} = DateTime.now("Etc/UTC")
      params = %{role: "administrator", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      Accounts.create_course__role(user_faculty, user_student, course, params)
      section_list = Courses.list_user_sections(user_student)
      assert length(section_list) == 1
      retrieved_section = List.first(section_list)
      assert retrieved_section.id == section.id
      assert retrieved_section.crn == section.crn
      assert retrieved_section.title == section.title
      section_list = Courses.list_user_sections(user_student2)
      assert length(section_list) == 0
    end

    test "list_sections/1 returns all sections for a given course" do
      section = section_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      course = Courses.get_course!(section.course_id)
      semester = Courses.get_semester!(course.semester_id)
      params = %{department: "some department", name: "empty course", number: 42, allow_write: true, allow_read: true}
      {:ok, course2} = Courses.create_course(user_faculty, semester, params)
      section_list = Courses.list_sections(course)
      retrieved_section = List.first(section_list)
      assert retrieved_section.id == section.id
      assert retrieved_section.crn == section.crn
      assert retrieved_section.title == section.title
      section_list = Courses.list_sections(course2)
      assert length(section_list) == 0
    end

    test "list_user_sections/2 returns all sections in a course for which a user has a valid course role" do
      section = section_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      course = Courses.get_course!(section.course_id)
      semester = Courses.get_semester!(course.semester_id)
      params = %{department: "some department", name: "empty course", number: 42, allow_write: true, allow_read: true}
      {:ok, course2} = Courses.create_course(user_faculty, semester, params)
      user_faculty2 = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id 2"})
      section_list = Courses.list_user_sections(course, user_faculty)
      retrieved_section = List.first(section_list)
      assert retrieved_section.id == section.id
      assert retrieved_section.crn == section.crn
      assert retrieved_section.title == section.title
      section_list = Courses.list_user_sections(course2, user_faculty)
      assert length(section_list) == 0
      section_list = Courses.list_user_sections(course, user_faculty2)
      assert length(section_list) == 0
      section_list = Courses.list_user_sections(course2, user_faculty2)
      assert length(section_list) == 0
    end

    test "list_user_sections/2 returns no sections in a course for which a user has a valid course role if course roles ignored" do
      section = section_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      course = Courses.get_course!(section.course_id)
      section_list = Courses.list_user_sections(course, user_faculty)
      retrieved_section = List.first(section_list)
      assert retrieved_section.id == section.id
      assert retrieved_section.crn == section.crn
      assert retrieved_section.title == section.title
      section_list = Courses.list_user_sections(course, user_faculty, false)
      assert length(section_list) == 0
    end

    test "list_user_sections/2 returns all sections in a course for which a user has a valid section role" do
      section = section_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      user_student = ATest.user_fixture(%{is_faculty: false, net_id: "student net id"})
      course = Courses.get_course!(section.course_id)
      {:ok, current_time} = DateTime.now("Etc/UTC")
      #No role returns no sections
      section_list = Courses.list_user_sections(course, user_student)
      assert length(section_list) == 0
      #Expired role returns no sections
      params = %{role: "student", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, -7200, :second)}
      {:ok, section_role} = App.Accounts.create_section__role!(user_faculty, user_student, section, params)
      section_list = Courses.list_user_sections(course, user_student)
      assert length(section_list) == 0
      #Valid role returns one section
      params = %{role: "student", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      {:ok, section_role} = App.Accounts.update_section__role!(user_faculty, section_role, params)
      section_list = Courses.list_user_sections(course, user_student)
      assert length(section_list) == 1
      retrieved_section = List.first(section_list)
      assert retrieved_section.id == section.id
      assert retrieved_section.crn == section.crn
      assert retrieved_section.title == section.title
      #Yet to begin role returns no sections
      params = %{role: "student", valid_from: DateTime.add(current_time, 7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      {:ok, section_role} = App.Accounts.update_section__role!(user_faculty, section_role, params)
      section_list = Courses.list_user_sections(course, user_student)
      assert length(section_list) == 0
      #Invalid role returns no sections
      params = %{role: "invalid role", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      App.Accounts.update_section__role!(user_faculty, section_role, params)
      section_list = Courses.list_user_sections(course, user_student)
      assert length(section_list) == 0
    end

    test "list_user_sections/1 returns no sections if user roles expired" do
      section = section_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      user_student = ATest.user_fixture(%{is_faculty: false, net_id: "student net id"})
      {:ok, current_time} = DateTime.now("Etc/UTC")
      #Expired role returns no sections
      params = %{role: "student", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, -7200, :second)}
      {:ok, section_role} = Accounts.create_section__role!(user_faculty, user_student, section, params)
      section_list = Courses.list_user_sections(user_student)
      assert length(section_list) == 0
      #Valid role returns one section
      params = %{role: "student", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      {:ok, section_role} = Accounts.update_section__role!(user_faculty, section_role, params)
      section_list = Courses.list_user_sections(user_student)
      assert length(section_list) == 1
      #Yet to begin role returns no sections
      params = %{role: "student", valid_from: DateTime.add(current_time, 7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      Accounts.update_section__role!(user_faculty, section_role, params)
      section_list = Courses.list_user_sections(user_student)
      assert length(section_list) == 0
    end

    test "list_user_sections/1 returns no sections if course.allow_read == false" do
      section = section_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      user_student = ATest.user_fixture(%{is_faculty: false, net_id: "student net id"})
      {:ok, current_time} = DateTime.now("Etc/UTC")
      params = %{role: "student", valid_from: DateTime.add(current_time, -7200, :second), valid_to: DateTime.add(current_time, 7200, :second)}
      Accounts.create_section__role!(user_faculty, user_student, section, params)
      course = Courses.get_course!(section.course_id)
      Courses.update_course(user_faculty, course, %{allow_read: false})
      section_list = Courses.list_user_sections(user_student)
      assert length(section_list) == 0
    end

    test "get_section!/1 returns the section with given id" do
      section = section_fixture()
      retrieved_section = Courses.get_section!(section.id)
      assert retrieved_section.id == section.id
      assert retrieved_section.crn == section.crn
      assert retrieved_section.title == section.title
    end

    test "get_user_section/1 returns the section with given id if user can view" do
      section = section_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      assert {:ok, retrieved_section} = Courses.get_user_section(user_faculty, section.id)
      assert retrieved_section.id == section.id
      assert retrieved_section.crn == section.crn
      assert retrieved_section.title == section.title
    end

    test "get_user_section/1 returns error if user cannot view or section does not exist" do
      section = section_fixture()
      user = ATest.user_fixture(%{is_faculty: false, net_id: "student net id"})
      assert {:error, message} = Courses.get_user_section(user, section.id)
      assert message = "forbidden"
      assert {:error, message} = Courses.get_user_section(user, section.id + 1)
      assert message = "not found"
    end

    test "create_section/3 with valid data creates a section" do
      course = course_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")

      assert {:ok, %Section{} = section} = Courses.create_section(user_faculty, course, @valid_attrs)
      assert section.crn == "some crn"
      assert section.title == "some title"
      assert {:error, changeset = section} = Courses.create_section(user_faculty, course, @valid_attrs)
      assert %{crn: ["has already been taken"]} = errors_on(changeset)
    end

    test "create_section/3 with invalid data returns error changeset" do
      course = course_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")

      assert {:error, %Ecto.Changeset{}} = Courses.create_section(user_faculty, course, @invalid_attrs)
    end

    test "create_section/3 as unauthorized user returns error" do
      course = course_fixture()
      user_noauth = ATest.user_fixture()

      assert {:error, "unauthorized"} = Courses.create_section(user_noauth, course, @valid_attrs)
    end

    test "create_section/3 on non-writeable course returns error" do
      course = course_fixture(%{allow_write: false})
      user_faculty = Accounts.get_user_by!("faculty net id")

      assert {:error, "course write not allowed"} = Courses.create_section(user_faculty, course, @valid_attrs)
    end

    test "update_section/3 with valid data updates the section" do
      section = section_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")

      assert {:ok, %Section{} = section} = Courses.update_section!(user_faculty, section, @update_attrs)
      assert section.crn == "some updated crn"
      assert section.title == "some updated title"
    end

    test "update_section/3 with invalid data returns error changeset" do
      section = section_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")

      assert {:error, %Ecto.Changeset{}} = Courses.update_section!(user_faculty, section, @invalid_attrs)
      retrieved_section = Courses.get_section!(section.id)
      assert retrieved_section.id == section.id
      assert retrieved_section.crn == section.crn
      assert retrieved_section.title == section.title
    end

    test "update_section/3 by unauthorized user returns error" do
      section = section_fixture()
      user_noauth = ATest.user_fixture()

      assert {:error, "unauthorized"} = Courses.update_section!(user_noauth, section, @invalid_attrs)
    end

    test "update_section/3 on non-writeable course returns error" do
      section = section_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      course = Courses.get_course!(section.course_id)
      Courses.update_course(user_faculty, course, %{allow_write: false})

      assert {:error, "course write not allowed"} = Courses.update_section!(user_faculty, section, @update_attrs)
    end

    test "delete_section/2 deletes the section" do
      section = section_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")

      assert {:ok, %Section{}} = Courses.delete_section!(user_faculty, section)
      assert_raise Ecto.NoResultsError, fn -> Courses.get_section!(section.id) end
    end

    test "delete_section/2 by unauthorized user returns error" do
      section = section_fixture()
      user_noauth = ATest.user_fixture()

      assert {:error, "unauthorized"} = Courses.delete_section!(user_noauth, section)
      retrieved_section = Courses.get_section!(section.id)
      assert retrieved_section.id == section.id
      assert retrieved_section.crn == section.crn
      assert retrieved_section.title == section.title
    end

    test "delete_section/2 on non-writeable course returns error" do
      section = section_fixture()
      user_faculty = Accounts.get_user_by!("faculty net id")
      course = Courses.get_course!(section.course_id)
      Courses.update_course(user_faculty, course, %{allow_write: false})

      assert {:error, "course write not allowed"} = Courses.delete_section!(user_faculty, section)
    end

    test "change_section/1 returns a section changeset" do
      section = section_fixture()
      assert %Ecto.Changeset{} = Courses.change_section(section)
    end
  end
end
