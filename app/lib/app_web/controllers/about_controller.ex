defmodule AppWeb.AboutController do
  use AppWeb, :controller
  alias App.Courses
  alias App.Courses.Course
  alias App.Courses.Section

  def index(conn, _params) do
    render(conn, "index.html", [current_user: nil, is_faculty: false])
  end
end
