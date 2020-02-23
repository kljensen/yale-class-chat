defmodule AppWeb.Section_RoleControllerTest do
  use AppWeb.ConnCase
  @moduletag :skip

  alias App.Accounts

  @create_attrs %{role: "some role", valid_from: "2010-04-17T14:00:00Z", valid_to: "2010-04-17T14:00:00Z"}
  @update_attrs %{role: "some updated role", valid_from: "2011-05-18T15:01:01Z", valid_to: "2011-05-18T15:01:01Z"}
  @invalid_attrs %{role: nil, valid_from: nil, valid_to: nil}

  def fixture(:section__role) do
    {:ok, section__role} = Accounts.create_section__role(@create_attrs)
    section__role
  end

  describe "index" do
    test "lists all section_roles", %{conn: conn} do
      conn = get(conn, Routes.section__role_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Section roles"
    end
  end

  describe "new section__role" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.section__role_path(conn, :new))
      assert html_response(conn, 200) =~ "New Section  role"
    end
  end

  describe "create section__role" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.section__role_path(conn, :create), section__role: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.section__role_path(conn, :show, id)

      conn = get(conn, Routes.section__role_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Section  role"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.section__role_path(conn, :create), section__role: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Section  role"
    end
  end

  describe "edit section__role" do
    setup [:create_section__role]

    test "renders form for editing chosen section__role", %{conn: conn, section__role: section__role} do
      conn = get(conn, Routes.section__role_path(conn, :edit, section__role))
      assert html_response(conn, 200) =~ "Edit Section  role"
    end
  end

  describe "update section__role" do
    setup [:create_section__role]

    test "redirects when data is valid", %{conn: conn, section__role: section__role} do
      conn = put(conn, Routes.section__role_path(conn, :update, section__role), section__role: @update_attrs)
      assert redirected_to(conn) == Routes.section__role_path(conn, :show, section__role)

      conn = get(conn, Routes.section__role_path(conn, :show, section__role))
      assert html_response(conn, 200) =~ "some updated role"
    end

    test "renders errors when data is invalid", %{conn: conn, section__role: section__role} do
      conn = put(conn, Routes.section__role_path(conn, :update, section__role), section__role: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Section  role"
    end
  end

  describe "delete section__role" do
    setup [:create_section__role]

    test "deletes chosen section__role", %{conn: conn, section__role: section__role} do
      conn = delete(conn, Routes.section__role_path(conn, :delete, section__role))
      assert redirected_to(conn) == Routes.section__role_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.section__role_path(conn, :show, section__role))
      end
    end
  end

  defp create_section__role(_) do
    section__role = fixture(:section__role)
    {:ok, section__role: section__role}
  end
end
