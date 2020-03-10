defmodule AppWeb.PageViewTest do
  use AppWeb.ConnCase, async: true
  import Phoenix.View

  test "renders index.html", %{conn: conn} do

    content = render_to_string(
      AppWeb.PageView,
      "index.html",
      conn: conn,
      current_user: nil,
      is_faculty: false)

    assert String.contains?(content, "Welcome")

  end
end
