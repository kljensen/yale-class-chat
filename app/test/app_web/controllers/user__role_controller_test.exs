defmodule AppWeb.User_RoleControllerTest do
  use AppWeb.ConnCase

  alias App.Accounts

  @create_attrs %{role: "some role", valid_from: "2010-04-17T14:00:00Z", valid_to: "2010-04-17T14:00:00Z"}
  @update_attrs %{role: "some updated role", valid_from: "2011-05-18T15:01:01Z", valid_to: "2011-05-18T15:01:01Z"}
  @invalid_attrs %{role: nil, valid_from: nil, valid_to: nil}

  def fixture(:user__role) do
    {:ok, user__role} = Accounts.create_user__role(@create_attrs)
    user__role
  end

  describe "index" do
    @tag :skip
    test "lists all user_roles", %{conn: conn} do
      conn = get(conn, Routes.user__role_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing User roles"
    end
  end

  describe "new user__role" do
    @tag :skip
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.user__role_path(conn, :new))
      assert html_response(conn, 200) =~ "New User  role"
    end
  end

  describe "create user__role" do
    @tag :skip
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user__role_path(conn, :create), user__role: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user__role_path(conn, :show, id)

      conn = get(conn, Routes.user__role_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show User  role"
    end

    @tag :skip
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user__role_path(conn, :create), user__role: @invalid_attrs)
      assert html_response(conn, 200) =~ "New User  role"
    end
  end

  describe "edit user__role" do
    setup [:create_user__role]

    @tag :skip
    test "renders form for editing chosen user__role", %{conn: conn, user__role: user__role} do
      conn = get(conn, Routes.user__role_path(conn, :edit, user__role))
      assert html_response(conn, 200) =~ "Edit User  role"
    end
  end

  describe "update user__role" do
    setup [:create_user__role]

    @tag :skip
    test "redirects when data is valid", %{conn: conn, user__role: user__role} do
      conn = put(conn, Routes.user__role_path(conn, :update, user__role), user__role: @update_attrs)
      assert redirected_to(conn) == Routes.user__role_path(conn, :show, user__role)

      conn = get(conn, Routes.user__role_path(conn, :show, user__role))
      assert html_response(conn, 200) =~ "some updated role"
    end

    @tag :skip
    test "renders errors when data is invalid", %{conn: conn, user__role: user__role} do
      conn = put(conn, Routes.user__role_path(conn, :update, user__role), user__role: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User  role"
    end
  end

  describe "delete user__role" do
    setup [:create_user__role]

    @tag :skip
    test "deletes chosen user__role", %{conn: conn, user__role: user__role} do
      conn = delete(conn, Routes.user__role_path(conn, :delete, user__role))
      assert redirected_to(conn) == Routes.user__role_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.user__role_path(conn, :show, user__role))
      end
    end
  end

  defp create_user__role(_) do
    user__role = fixture(:user__role)
    {:ok, user__role: user__role}
  end
end
