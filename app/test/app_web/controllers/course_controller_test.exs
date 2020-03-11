defmodule AppWeb.CourseControllerTest do
  use AppWeb.ConnCase

  alias App.Courses
  alias App.AccountsTest, as: ATest
  import Plug.Test

  def fixture(:semester) do
    semester = App.CoursesTest.semester_fixture()
    semester
  end

  @create_attrs %{department: "some department", name: "some name", number: 42, allow_write: true, allow_read: true}
  @update_attrs %{department: "some updated department", name: "some updated name", number: 43, allow_write: false, allow_read: false}
  @invalid_attrs %{department: nil, name: nil, number: nil, allow_write: nil, allow_read: nil}

  def fixture(:course) do
    semester = App.CoursesTest.semester_fixture()
    user_faculty = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id"})
    {:ok, course} = Courses.create_course(user_faculty, semester, @create_attrs)
    course
  end

  describe "index" do
    test "lists all courses", %{conn: conn} do
      _course = fixture(:course)
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.course_path(conn, :index))

      assert html_response(conn, 200) =~ "Listing Courses"
    end
  end

  describe "new course" do
    test "renders form", %{conn: conn} do
      _user_faculty = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id"})
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.course_path(conn, :new))
      assert html_response(conn, 200) =~ "New Course"
    end
  end

  describe "create course" do
    test "redirects to show when data is valid", %{conn: conn} do
      _user_faculty = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id"})
      semester = App.CoursesTest.semester_fixture()
      attrs = Map.merge(@create_attrs, %{semester_id: semester.id})
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.course_path(conn, :create), course: attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.course_path(conn, :show, id)

      conn = get(conn, Routes.course_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Course Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      _user_faculty = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id"})
      semester = App.CoursesTest.semester_fixture()
      attrs = Map.merge(@invalid_attrs, %{semester_id: semester.id})
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.course_path(conn, :create), course: attrs)
      assert html_response(conn, 200) =~ "New Course"
    end
  end

  describe "edit course" do
    setup [:create_course]

    test "renders form for editing chosen course", %{conn: conn, course: course} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.course_path(conn, :edit, course))
      assert html_response(conn, 200) =~ "Edit Course"
    end
  end

  describe "update course" do
    setup [:create_course]

    test "redirects when data is valid", %{conn: conn, course: course} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> put(Routes.course_path(conn, :update, course), course: @update_attrs)
      assert redirected_to(conn) == Routes.course_path(conn, :show, course)

      conn = get(conn, Routes.course_path(conn, :show, course))
      assert html_response(conn, 200) =~ "some updated department"
    end

    test "renders errors when data is invalid", %{conn: conn, course: course} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> put(Routes.course_path(conn, :update, course), course: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Course"
    end
  end

  describe "delete course" do
    setup [:create_course]

    test "deletes chosen course", %{conn: conn, course: course} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> delete(Routes.course_path(conn, :delete, course))
      assert redirected_to(conn) == Routes.course_path(conn, :index)
      conn = get(conn, Routes.course_path(conn, :show, course))
      assert html_response(conn, 404) =~ "Not Found"
    end
  end

  defp create_course(_) do
    course = fixture(:course)
    {:ok, course: course}
  end
end
