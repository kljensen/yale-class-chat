defmodule AppWeb.PageController do
  use AppWeb, :controller

  def index(conn, _params) do
    uid = get_session(conn, :uid)
    IO.inspect uid
    render(conn, "index.html", current_user: uid)
  end
end
