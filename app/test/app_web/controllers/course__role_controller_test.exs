defmodule AppWeb.Course_RoleControllerTest do
  use AppWeb.ConnCase
  import Plug.Test

  alias App.Accounts

  @create_attrs %{role: "administrator", valid_from: "2010-04-17T14:00:00Z", valid_to: "2010-04-17T14:00:00Z"}
  @update_attrs %{role: "some updated role", valid_from: "2011-05-18T15:01:01Z", valid_to: "2011-05-18T15:01:01Z"}
  @invalid_attrs %{role: nil, valid_from: nil, valid_to: nil}

  setup [:create_course_and_student]

  def fixture(:course__role, course, student) do
    user_faculty = App.Accounts.get_user_by!("faculty net id")
    {:ok, course__role} = Accounts.create_course__role(user_faculty, student, course, @create_attrs)
    course__role
  end

  describe "index" do
    test "lists all course_roles", %{conn: conn, course: course} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.course_course__role_path(conn, :index, course))
      assert html_response(conn, 200) =~ "Listing Course roles"
    end
  end

  describe "new course__role" do
    test "renders form", %{conn: conn, course: course} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.course_course__role_path(conn, :new, course))
      assert html_response(conn, 200) =~ "New Course  role"
    end
  end

  describe "create course__role" do
    test "redirects to show when data is valid", %{conn: conn, course: course} do
      current_user = Accounts.get_user_by!("faculty net id")
      attrs = Map.merge(@create_attrs, %{user_id: current_user.id})
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.course_course__role_path(conn, :create, course), course__role: attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.course_course__role_path(conn, :show, course, id)

      conn = get(conn, Routes.course_course__role_path(conn, :show, course, id))
      assert html_response(conn, 200) =~ "Show Course  role"
    end

    test "renders errors when data is invalid", %{conn: conn, course: course} do
      current_user = Accounts.get_user_by!("faculty net id")
      attrs = Map.merge(@invalid_attrs, %{user_id: current_user.id})
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.course_course__role_path(conn, :create, course), course__role: attrs)
      assert html_response(conn, 200) =~ "New Course  role"
    end
  end

  describe "edit course__role" do
    setup [:create_course__role]

    test "renders form for editing chosen course__role", %{conn: conn, course__role: course__role} do
      course = App.Courses.get_course!(course__role.course_id)
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.course_course__role_path(conn, :edit, course, course__role))
      assert html_response(conn, 200) =~ "Edit Course  role"
    end
  end

  describe "update course__role" do
    setup [:create_course__role]

    test "redirects when data is valid", %{conn: conn, course__role: course__role} do
      course = App.Courses.get_course!(course__role.course_id)
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> put(Routes.course_course__role_path(conn, :update, course, course__role), course__role: @update_attrs)
      assert redirected_to(conn) == Routes.course_course__role_path(conn, :show, course, course__role)

      conn = get(conn, Routes.course_course__role_path(conn, :show, course, course__role))
      assert html_response(conn, 200) =~ "some updated role"
    end

    test "renders errors when data is invalid", %{conn: conn, course__role: course__role} do
      course = App.Courses.get_course!(course__role.course_id)
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> put(Routes.course_course__role_path(conn, :update, course, course__role), course__role: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Course  role"
    end
  end

  describe "delete course__role" do
    setup [:create_course__role]

    test "deletes chosen course__role", %{conn: conn, course__role: course__role} do
      course = App.Courses.get_course!(course__role.course_id)
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> delete(Routes.course_course__role_path(conn, :delete, course, course__role))
      assert redirected_to(conn) == Routes.course_course__role_path(conn, :index, course)
      assert_error_sent 404, fn ->
        get(conn, Routes.course_course__role_path(conn, :show, course, course__role))
      end
    end
  end

  defp create_course__role(params) do
    course = params.course
    student = params.student
    course__role = fixture(:course__role, course, student)
    {:ok, course__role: course__role}
  end

  defp create_course_and_student(_) do
    course = AppWeb.CourseControllerTest.fixture(:course)
    student = AppWeb.UserControllerTest.fixture(:user)
    {:ok, [course: course, student: student]}
  end
end
