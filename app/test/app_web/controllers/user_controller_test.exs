defmodule AppWeb.UserControllerTest do
  use AppWeb.ConnCase

  alias App.Accounts
  import Plug.Test

  @create_attrs %{display_name: "some display_name", email: "some_email@yale.edu", net_id: "some net_id"}
  @update_attrs %{display_name: "some updated display_name", email: "some_updated_email@yale.edu", net_id: "some net_id"}
  @invalid_attrs %{display_name: nil, email: nil, net_id: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = conn
        |> init_test_session(uid: @create_attrs.net_id)
        |> get(Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = conn
        |> init_test_session(uid: @create_attrs.net_id)
        |> put(Routes.user_path(conn, :update, user), user: @update_attrs)
        assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "some updated display_name"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = conn
        |> init_test_session(uid: @create_attrs.net_id)
        |> put(Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
