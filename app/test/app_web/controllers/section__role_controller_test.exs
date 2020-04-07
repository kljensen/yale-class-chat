defmodule AppWeb.Section_RoleControllerTest do
  use AppWeb.ConnCase
  import Plug.Test

  alias App.Accounts

  @create_attrs %{role: "some role", valid_from: "2010-04-17T14:00", valid_to: "2010-04-17T14:00"}
  @update_attrs %{role: "some updated role", valid_from: "2011-05-18T15:01", valid_to: "2011-05-18T15:01"}
  @invalid_attrs %{role: nil, valid_from: nil, valid_to: nil}

  setup [:create_section_and_student]

  def fixture(:section__role, section, student) do
    user_faculty = App.Accounts.get_user_by!("faculty net id")
    {:ok, section__role} = Accounts.create_section__role!(user_faculty, student, section, @create_attrs)
    section__role
  end

  describe "index" do
    test "lists all section_roles", %{conn: conn, section: section} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.section_section__role_path(conn, :index, section))
      assert html_response(conn, 200) =~ "Listing Section roles"
    end
  end

  describe "new section__role" do
    test "renders form", %{conn: conn, section: section} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.section_section__role_path(conn, :new, section))
      assert html_response(conn, 200) =~ "New Section role"
    end
  end

  describe "create section__role" do
    test "redirects to show when data is valid", %{conn: conn, section: section} do
      current_user = Accounts.get_user_by!("faculty net id")
      attrs = Map.merge(@create_attrs, %{user_id: current_user.id})
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.section_section__role_path(conn, :create, section), section__role: attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.section_section__role_path(conn, :show, section, id)

      conn = get(conn, Routes.section_section__role_path(conn, :show, section, id))
      assert html_response(conn, 200) =~ "Show Section role"
    end

    test "renders errors when data is invalid", %{conn: conn, section: section} do
      current_user = Accounts.get_user_by!("faculty net id")
      attrs = Map.merge(@invalid_attrs, %{user_id: current_user.id})
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.section_section__role_path(conn, :create, section), section__role: attrs)
      assert html_response(conn, 200) =~ "New Section role"
    end
  end

  describe "bulk new section__role" do
    test "renders form", %{conn: conn, section: section} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.section_section__role_path(conn, :bulk_new, section))
      assert html_response(conn, 200) =~ "Add Section Roles"
    end
  end

  describe "bulk create section__role" do
    test "redirects to show when data is valid", %{conn: conn, section: section} do
      attrs = Map.merge(@create_attrs, %{"user_id_list" => "abc123, abc234"})
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.section_section__role_path(conn, :bulk_create, section), section__role: attrs)

      assert %{section_id: section_id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.section_section__role_path(conn, :index, section_id)

      conn = get(conn, Routes.section_section__role_path(conn, :index, section_id))
      assert html_response(conn, 200) =~ "abc123"
      assert html_response(conn, 200) =~ "abc234"
    end

    test "renders errors when data is invalid", %{conn: conn, section: section} do
      attrs = Map.merge(@invalid_attrs, %{"user_id_list" => "abc123, abc234"})
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.section_section__role_path(conn, :bulk_create, section), section__role: attrs)
      assert html_response(conn, 200) =~ "Add Section Roles"
    end
  end

  describe "api new section__role" do
    test "renders form", %{conn: conn, section: section} do
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.section_section__role_path(conn, :api_new, section))
      assert html_response(conn, 200) =~ "Add Section Roles From Course Registrations"
    end
  end

  describe "api create section__role" do
    @describetag :skip #Skip API tests to avoid hitting the API too often
    test "redirects to show when data is valid", %{conn: conn, section: section} do
      current_user = Accounts.get_user_by!("faculty net id")
      #Update semester termcode and section CRN to return valid data
      App.Courses.update_section!(current_user, section, %{crn: "12801"})
      course = App.Courses.get_course!(section.course_id)
      semester = App.Courses.get_semester!(course.semester_id)
      App.Courses.update_semester(current_user, semester, %{term_code: "201903"})
      attrs = Map.merge(@create_attrs, %{"update existing" => "false", "overwrite" => "false"})
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.section_section__role_path(conn, :api_create, section), section__role: attrs)

      assert %{section_id: section_id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.section_section__role_path(conn, :index, section_id)

      conn = get(conn, Routes.section_section__role_path(conn, :index, section_id))
      assert html_response(conn, 200) =~ "njp37"
    end

    test "renders errors when data is invalid", %{conn: conn, section: section} do
      current_user = Accounts.get_user_by!("faculty net id")
      attrs = Map.merge(@invalid_attrs, %{"update existing" => "false", "overwrite" => "false"})
      App.Courses.update_section!(current_user, section, %{crn: "111111"})
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> post(Routes.section_section__role_path(conn, :api_create, section), section__role: attrs)
      assert html_response(conn, 200) =~ "Add Section Roles From Course Registrations"
    end
  end

  describe "edit section__role" do
    setup [:create_section__role]

    test "renders form for editing chosen section__role", %{conn: conn, section__role: section__role} do
      section = App.Courses.get_section!(section__role.section_id)
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.section_section__role_path(conn, :edit, section, section__role))
      assert html_response(conn, 200) =~ "Edit Section role"
    end
  end

  describe "update section__role" do
    setup [:create_section__role]

    test "redirects when data is valid", %{conn: conn, section__role: section__role} do
      section = App.Courses.get_section!(section__role.section_id)
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> put(Routes.section_section__role_path(conn, :update, section, section__role), section__role: @update_attrs)
      assert redirected_to(conn) == Routes.section_section__role_path(conn, :show, section, section__role)

      conn = get(conn, Routes.section_section__role_path(conn, :show, section, section__role))
      assert html_response(conn, 200) =~ "some updated role"
    end

    test "renders errors when data is invalid", %{conn: conn, section__role: section__role} do
      section = App.Courses.get_section!(section__role.section_id)
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> put(Routes.section_section__role_path(conn, :update, section, section__role), section__role: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Section role"
    end
  end

  describe "delete section__role" do
    setup [:create_section__role]

    test "deletes chosen section__role", %{conn: conn, section__role: section__role} do
      section = App.Courses.get_section!(section__role.section_id)
      conn = conn
        |> init_test_session(uid: "faculty net id")
        |> delete(Routes.section_section__role_path(conn, :delete, section, section__role))
      assert redirected_to(conn) == Routes.section_section__role_path(conn, :index, section)
      assert_error_sent 404, fn ->
        get(conn, Routes.section_section__role_path(conn, :show, section, section__role))
      end
    end
  end

  defp create_section__role(params) do
    section = params.section
    student = params.student
    section__role = fixture(:section__role, section, student)
    {:ok, section__role: section__role}
  end

  defp create_section_and_student(_) do
    section = AppWeb.SectionControllerTest.fixture(:section)
    student = AppWeb.UserControllerTest.fixture(:user)
    {:ok, [section: section, student: student]}
  end

end
