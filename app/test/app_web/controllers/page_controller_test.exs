defmodule AppWeb.PageControllerTest do
  use AppWeb.ConnCase
  @moduletag :skip

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Current user"
    assert html_response(conn, 200) =~ "Foo"
  end
end
