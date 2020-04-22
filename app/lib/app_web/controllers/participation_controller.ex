defmodule AppWeb.ParticipationController do
  use AppWeb, :controller

  def course(conn, _params) do
    current_user = conn.assigns.current_user
    render(conn, "index.html", [current_user: current_user])
  end

  def section(conn, _params) do
    current_user = conn.assigns.current_user
    render(conn, "index.html", [current_user: current_user])
  end
end
