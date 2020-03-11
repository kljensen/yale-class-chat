defmodule AppWeb.UserSectionController do
  use AppWeb, :controller

  alias App.Courses
  alias App.Courses.Section

  def index(conn, _params) do
    user = conn.assigns.current_user
    sections = Courses.list_user_sections(user)
    render(conn, "index.html", sections: sections)
  end

end
