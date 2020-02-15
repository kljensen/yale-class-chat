defmodule App.CoursesTest do
  use App.DataCase

  alias App.Courses

  describe "semesters" do
    alias App.Courses.Semester

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def semester_fixture(attrs \\ %{}) do
      {:ok, semester} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Courses.create_semester()

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

    test "create_semester/1 with valid data creates a semester" do
      assert {:ok, %Semester{} = semester} = Courses.create_semester(@valid_attrs)
      assert semester.name == "some name"
      assert {:error, changeset = semester} = Courses.create_semester(@valid_attrs)
      assert %{name: ["has already been taken"]} = errors_on(changeset)
    end

    test "create_semester/1 with invalid data returns error changeset" do
      assert {:error, changeset = semester} = Courses.create_semester(@invalid_attrs)
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "update_semester/2 with valid data updates the semester" do
      semester = semester_fixture()
      assert {:ok, %Semester{} = semester} = Courses.update_semester(semester, @update_attrs)
      assert semester.name == "some updated name"
    end

    test "update_semester/2 with invalid data returns error changeset" do
      semester = semester_fixture()
      assert {:error, %Ecto.Changeset{}} = Courses.update_semester(semester, @invalid_attrs)
      assert semester == Courses.get_semester!(semester.id)
    end

    test "delete_semester/1 deletes the semester" do
      semester = semester_fixture()
      assert {:ok, %Semester{}} = Courses.delete_semester(semester)
      assert_raise Ecto.NoResultsError, fn -> Courses.get_semester!(semester.id) end
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
      {:ok, course} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Courses.create_course()

      course
    end

    test "list_courses/0 returns all courses" do
      course = course_fixture()
      assert Courses.list_courses() == [course]
    end

    test "get_course!/1 returns the course with given id" do
      course = course_fixture()
      assert Courses.get_course!(course.id) == course
    end

    test "create_course/1 with valid data creates a course" do
      assert {:ok, %Course{} = course} = Courses.create_course(@valid_attrs)
      assert course.department == "some department"
      assert course.name == "some name"
      assert course.number == 42
    end

    test "create_course/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Courses.create_course(@invalid_attrs)
    end

    test "update_course/2 with valid data updates the course" do
      course = course_fixture()
      assert {:ok, %Course{} = course} = Courses.update_course(course, @update_attrs)
      assert course.department == "some updated department"
      assert course.name == "some updated name"
      assert course.number == 43
    end

    test "update_course/2 with invalid data returns error changeset" do
      course = course_fixture()
      assert {:error, %Ecto.Changeset{}} = Courses.update_course(course, @invalid_attrs)
      assert course == Courses.get_course!(course.id)
    end

    test "delete_course/1 deletes the course" do
      course = course_fixture()
      assert {:ok, %Course{}} = Courses.delete_course(course)
      assert_raise Ecto.NoResultsError, fn -> Courses.get_course!(course.id) end
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
      {:ok, section} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Courses.create_section()

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

    test "create_section/1 with valid data creates a section" do
      assert {:ok, %Section{} = section} = Courses.create_section(@valid_attrs)
      assert section.crn == "some crn"
      assert section.title == "some title"
      assert {:error, changeset = section} = Courses.create_section(@valid_attrs)
      assert %{crn: ["has already been taken"]} = errors_on(changeset)
    end

    test "create_section/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Courses.create_section(@invalid_attrs)
    end

    test "update_section/2 with valid data updates the section" do
      section = section_fixture()
      assert {:ok, %Section{} = section} = Courses.update_section(section, @update_attrs)
      assert section.crn == "some updated crn"
      assert section.title == "some updated title"
    end

    test "update_section/2 with invalid data returns error changeset" do
      section = section_fixture()
      assert {:error, %Ecto.Changeset{}} = Courses.update_section(section, @invalid_attrs)
      assert section == Courses.get_section!(section.id)
    end

    test "delete_section/1 deletes the section" do
      section = section_fixture()
      assert {:ok, %Section{}} = Courses.delete_section(section)
      assert_raise Ecto.NoResultsError, fn -> Courses.get_section!(section.id) end
    end

    test "change_section/1 returns a section changeset" do
      section = section_fixture()
      assert %Ecto.Changeset{} = Courses.change_section(section)
    end
  end
end
