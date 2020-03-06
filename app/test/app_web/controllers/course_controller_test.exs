defmodule AppWeb.CourseControllerTest do
  use AppWeb.ConnCase
  @moduletag :skip

  alias App.Courses
  alias App.Accounts
  alias App.AccountsTest, as: ATest
  import Plug.Test

  def fixture(:semester) do
    semester = App.CoursesTest.semester_fixture()
    semester
  end

  @create_attrs %{department: "some department", name: "some name", number: 42}
  @update_attrs %{department: "some updated department", name: "some updated name", number: 43}
  @invalid_attrs %{department: nil, name: nil, number: nil}

  def fixture(:course) do
    semester = App.CoursesTest.semester_fixture()
    user_faculty = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id"})
    {:ok, course} = Courses.create_course(user_faculty, semester, @create_attrs)
    course
  end

  describe "index" do
    test "lists all courses", %{conn: conn} do
      course = fixture(:course)
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(conn, Routes.course_path(conn, :index))

      assert html_response(conn, 200) =~ "Listing Courses"
    end
  end

  describe "new course" do
    test "renders form", %{conn: conn} do
      user_faculty = ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id"})
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.course_path(conn, :new))
      assert html_response(conn, 200) =~ "New Course"
    end
  end

  describe "create course" do
    test "redirects to show when data is valid", %{conn: conn} do
      semester = App.CoursesTest.semester_fixture()
      conn = post(conn, Routes.course_path(conn, :create), semester: semester, course: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.course_path(conn, :show, id)

      conn = get(conn, Routes.course_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Course"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      semester = App.CoursesTest.semester_fixture()
      conn = post(conn, Routes.course_path(conn, :create), semester: semester, course: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Course"
    end
  end

  describe "edit course" do
    setup [:create_course]

    test "renders form for editing chosen course", %{conn: conn, course: course} do
      conn = get(conn, Routes.course_path(conn, :edit, course))
      assert html_response(conn, 200) =~ "Edit Course"
    end
  end

  describe "update course" do
    setup [:create_course]

    test "redirects when data is valid", %{conn: conn, course: course} do
      conn = put(conn, Routes.course_path(conn, :update, course), course: @update_attrs)
      assert redirected_to(conn) == Routes.course_path(conn, :show, course)

      conn = get(conn, Routes.course_path(conn, :show, course))
      assert html_response(conn, 200) =~ "some updated department"
    end

    test "renders errors when data is invalid", %{conn: conn, course: course} do
      conn = put(conn, Routes.course_path(conn, :update, course), course: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Course"
    end
  end

  describe "delete course" do
    setup [:create_course]

    test "deletes chosen course", %{conn: conn, course: course} do
      conn = delete(conn, Routes.course_path(conn, :delete, course))
      assert redirected_to(conn) == Routes.course_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.course_path(conn, :show, course))
      end
    end
  end

  defp create_course(_) do
    course = fixture(:course)
    {:ok, course: course}
  end
end
