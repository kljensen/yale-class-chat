defmodule AppWeb.Course_RoleControllerTest do
  use AppWeb.ConnCase
  @moduletag :skip

  alias App.Accounts

  @create_attrs %{role: "some role", valid_from: "2010-04-17T14:00:00Z", valid_to: "2010-04-17T14:00:00Z"}
  @update_attrs %{role: "some updated role", valid_from: "2011-05-18T15:01:01Z", valid_to: "2011-05-18T15:01:01Z"}
  @invalid_attrs %{role: nil, valid_from: nil, valid_to: nil}

  def fixture(:course__role) do
    {:ok, course__role} = Accounts.create_course__role(@create_attrs)
    course__role
  end

  describe "index" do
    test "lists all course_roles", %{conn: conn} do
      conn = get(conn, Routes.course__role_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Course roles"
    end
  end

  describe "new course__role" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.course__role_path(conn, :new))
      assert html_response(conn, 200) =~ "New Course  role"
    end
  end

  describe "create course__role" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.course__role_path(conn, :create), course__role: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.course__role_path(conn, :show, id)

      conn = get(conn, Routes.course__role_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Course  role"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.course__role_path(conn, :create), course__role: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Course  role"
    end
  end

  describe "edit course__role" do
    setup [:create_course__role]

    test "renders form for editing chosen course__role", %{conn: conn, course__role: course__role} do
      conn = get(conn, Routes.course__role_path(conn, :edit, course__role))
      assert html_response(conn, 200) =~ "Edit Course  role"
    end
  end

  describe "update course__role" do
    setup [:create_course__role]

    test "redirects when data is valid", %{conn: conn, course__role: course__role} do
      conn = put(conn, Routes.course__role_path(conn, :update, course__role), course__role: @update_attrs)
      assert redirected_to(conn) == Routes.course__role_path(conn, :show, course__role)

      conn = get(conn, Routes.course__role_path(conn, :show, course__role))
      assert html_response(conn, 200) =~ "some updated role"
    end

    test "renders errors when data is invalid", %{conn: conn, course__role: course__role} do
      conn = put(conn, Routes.course__role_path(conn, :update, course__role), course__role: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Course  role"
    end
  end

  describe "delete course__role" do
    setup [:create_course__role]

    test "deletes chosen course__role", %{conn: conn, course__role: course__role} do
      conn = delete(conn, Routes.course__role_path(conn, :delete, course__role))
      assert redirected_to(conn) == Routes.course__role_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.course__role_path(conn, :show, course__role))
      end
    end
  end

  defp create_course__role(_) do
    course__role = fixture(:course__role)
    {:ok, course__role: course__role}
  end
end
