defmodule AppWeb.PageController do
  use AppWeb, :controller

  def index(conn, _params) do
    case get_session(conn, :uid) do
      nil ->
        render(conn, "index.html", [current_user: nil, is_faculty: false])

      uid ->
        case App.Accounts.get_user_by(uid) do
          nil ->
            conn
            |> configure_session(drop: true)
            |> render("index.html", [current_user: nil, is_faculty: false])

          current_user ->
            is_faculty = current_user.is_faculty
            render(conn, "index.html", [current_user: current_user, is_faculty: is_faculty])
          end
      end
  end
end
