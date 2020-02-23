defmodule AppWeb.SectionControllerTest do
  use AppWeb.ConnCase
  @moduletag :skip

  alias App.Courses

  @create_attrs %{crn: "some crn", title: "some title"}
  @update_attrs %{crn: "some updated crn", title: "some updated title"}
  @invalid_attrs %{crn: nil, title: nil}

  def fixture(:section) do
    {:ok, section} = Courses.create_section(@create_attrs)
    section
  end

  describe "index" do
    test "lists all sections", %{conn: conn} do
      conn = get(conn, Routes.section_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Sections"
    end
  end

  describe "new section" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.section_path(conn, :new))
      assert html_response(conn, 200) =~ "New Section"
    end
  end

  describe "create section" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.section_path(conn, :create), section: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.section_path(conn, :show, id)

      conn = get(conn, Routes.section_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Section"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.section_path(conn, :create), section: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Section"
    end
  end

  describe "edit section" do
    setup [:create_section]

    test "renders form for editing chosen section", %{conn: conn, section: section} do
      conn = get(conn, Routes.section_path(conn, :edit, section))
      assert html_response(conn, 200) =~ "Edit Section"
    end
  end

  describe "update section" do
    setup [:create_section]

    test "redirects when data is valid", %{conn: conn, section: section} do
      conn = put(conn, Routes.section_path(conn, :update, section), section: @update_attrs)
      assert redirected_to(conn) == Routes.section_path(conn, :show, section)

      conn = get(conn, Routes.section_path(conn, :show, section))
      assert html_response(conn, 200) =~ "some updated crn"
    end

    test "renders errors when data is invalid", %{conn: conn, section: section} do
      conn = put(conn, Routes.section_path(conn, :update, section), section: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Section"
    end
  end

  describe "delete section" do
    setup [:create_section]

    test "deletes chosen section", %{conn: conn, section: section} do
      conn = delete(conn, Routes.section_path(conn, :delete, section))
      assert redirected_to(conn) == Routes.section_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.section_path(conn, :show, section))
      end
    end
  end

  defp create_section(_) do
    section = fixture(:section)
    {:ok, section: section}
  end
end
