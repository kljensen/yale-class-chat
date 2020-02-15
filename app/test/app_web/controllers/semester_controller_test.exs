defmodule AppWeb.SemesterControllerTest do
  use AppWeb.ConnCase

  alias App.Courses

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:semester) do
    {:ok, semester} = Courses.create_semester(@create_attrs)
    semester
  end

  describe "index" do
    test "lists all semesters", %{conn: conn} do
      conn = get(conn, Routes.semester_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Semesters"
    end
  end

  describe "new semester" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.semester_path(conn, :new))
      assert html_response(conn, 200) =~ "New Semester"
    end
  end

  describe "create semester" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.semester_path(conn, :create), semester: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.semester_path(conn, :show, id)

      conn = get(conn, Routes.semester_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Semester"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.semester_path(conn, :create), semester: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Semester"
    end
  end

  describe "edit semester" do
    setup [:create_semester]

    test "renders form for editing chosen semester", %{conn: conn, semester: semester} do
      conn = get(conn, Routes.semester_path(conn, :edit, semester))
      assert html_response(conn, 200) =~ "Edit Semester"
    end
  end

  describe "update semester" do
    setup [:create_semester]

    test "redirects when data is valid", %{conn: conn, semester: semester} do
      conn = put(conn, Routes.semester_path(conn, :update, semester), semester: @update_attrs)
      assert redirected_to(conn) == Routes.semester_path(conn, :show, semester)

      conn = get(conn, Routes.semester_path(conn, :show, semester))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, semester: semester} do
      conn = put(conn, Routes.semester_path(conn, :update, semester), semester: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Semester"
    end
  end

  describe "delete semester" do
    setup [:create_semester]

    test "deletes chosen semester", %{conn: conn, semester: semester} do
      conn = delete(conn, Routes.semester_path(conn, :delete, semester))
      assert redirected_to(conn) == Routes.semester_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.semester_path(conn, :show, semester))
      end
    end
  end

  defp create_semester(_) do
    semester = fixture(:semester)
    {:ok, semester: semester}
  end
end
