defmodule AppWeb.PageViewTest do
  use AppWeb.ConnCase, async: true
  import Phoenix.View

  test "renders index.html", %{conn: conn} do
    links = [
      Routes.course_path(conn, :index),
      Routes.submission_path(conn, :index),
      Routes.comment_path(conn, :index),
      Routes.rating_path(conn, :index)
    ]

    content = render_to_string(
      AppWeb.PageView,
      "index.html",
      conn: conn,
      current_user: nil,
      is_faculty: false)

    assert String.contains?(content, "Quick Links")

    for link <- links do
      assert String.contains?(content, link)
    end
  end
end
