defmodule AppWeb.AboutController do
  use AppWeb, :controller
  alias App.Courses
  alias App.Courses.Course
  alias App.Courses.Section

  def index(conn, _params) do
    current_user = conn.assigns.current_user
    render(conn, "index.html", [current_user: current_user])
  end
end
