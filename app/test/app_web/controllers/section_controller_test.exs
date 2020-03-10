defmodule AppWeb.SectionControllerTest do
  use AppWeb.ConnCase

  alias App.Courses
  import Plug.Test

  @create_attrs %{crn: "some crn", title: "some title"}
  @update_attrs %{crn: "some updated crn", title: "some updated title"}
  @invalid_attrs %{crn: nil, title: nil}

  def fixture(:section) do
    course = App.CoursesTest.course_fixture()
    user_faculty = App.Accounts.get_user_by!("faculty net id")
    {:ok, section} = Courses.create_section(user_faculty, course, @create_attrs)
    section
  end

  describe "index" do
    test "lists all sections", %{conn: conn} do
      section = fixture(:section)
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.course_section_path(conn, :index, section.course_id))
      assert html_response(conn, 200) =~ "Listing Sections"
    end
  end

  describe "new section" do
    test "renders form", %{conn: conn} do
      course = App.CoursesTest.course_fixture()
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.course_section_path(conn, :new, course.id))
      assert html_response(conn, 200) =~ "New Section"
    end
  end

  describe "create section" do
    test "redirects to show when data is valid", %{conn: conn} do
      course = App.CoursesTest.course_fixture()
      attrs = Map.merge(@create_attrs, %{course_id: course.id})
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.section_path(conn, :create), section: attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.section_path(conn, :show, id)

      conn = get(conn, Routes.section_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Section"
      assert html_response(conn, 200) =~ "Topics"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      course = App.CoursesTest.course_fixture()
      attrs = Map.merge(@invalid_attrs, %{course_id: course.id})
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.section_path(conn, :create), section: attrs)
      assert html_response(conn, 200) =~ "New Section"
    end
  end

  describe "edit section" do
    setup [:create_section]

    test "renders form for editing chosen section", %{conn: conn, section: section} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.section_path(conn, :edit, section))
      assert html_response(conn, 200) =~ "Edit Section"
    end
  end

  describe "update section" do
    setup [:create_section]

    test "redirects when data is valid", %{conn: conn, section: section} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> put(Routes.section_path(conn, :update, section), section: @update_attrs)
      assert redirected_to(conn) == Routes.section_path(conn, :show, section)

      conn = get(conn, Routes.section_path(conn, :show, section))
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, section: section} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> put(Routes.section_path(conn, :update, section), section: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Section"
    end
  end

  describe "delete section" do
    setup [:create_section]

    test "deletes chosen section", %{conn: conn, section: section} do
      course_id = section.course_id
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> delete(Routes.section_path(conn, :delete, section))
      assert redirected_to(conn) == Routes.course_section_path(conn, :index, course_id)
      conn = get(conn, Routes.section_path(conn, :show, section))
      assert html_response(conn, 404) =~ "Not Found"
    end
  end

  defp create_section(_) do
    section = fixture(:section)
    {:ok, section: section}
  end
end
