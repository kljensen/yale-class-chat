defmodule AppWeb.PageControllerTest do
  use AppWeb.ConnCase
  alias App.AccountsTest, as: ATest
  import Plug.Test

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "WELCOME"
    assert html_response(conn, 200) =~ "Log In"
  end

  test "Renders with valid user", %{conn: conn} do
    ATest.user_fixture(%{is_faculty: true, net_id: "faculty net id"})
    conn = conn
        |> init_test_session(uid: "faculty net id")
        |> get(Routes.page_path(conn, :index))
    assert html_response(conn, 200) =~ "New Course"
  end
end
