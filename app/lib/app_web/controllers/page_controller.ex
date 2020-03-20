defmodule AppWeb.PageController do
  use AppWeb, :controller
  alias App.Courses
  alias App.Courses.Course
  alias App.Courses.Section

  def index(conn, _params) do
    case get_session(conn, :uid) do
      nil ->
        render(conn, "index.html", [current_user: nil, is_faculty: false])

      uid ->
        case IO.inspect(App.Accounts.get_user_by(uid)) do
          nil ->
            conn
            |> configure_session(drop: true)
            |> render("index.html", [current_user: nil, is_faculty: false])

          user ->
            conn = conn
                    |> assign(:current_user, user)
                    |> assign(:user_signed_in?, true)

            case user.is_faculty do
              true ->
                courses = Courses.list_user_courses(user)
                list = Courses.list_semester_names()
                semesters = Map.new(Enum.map(list, fn [key, value] -> {:"#{key}", value} end))
                conn
                |> put_view(AppWeb.CourseView)
                |> render("index.html", [courses: courses, semesters: semesters])

              false ->
                sections = Courses.list_user_sections(user)
                conn
                |> put_view(AppWeb.UserSectionView)
                |> render("index.html", sections: sections)
              end
          end
      end
  end
end
