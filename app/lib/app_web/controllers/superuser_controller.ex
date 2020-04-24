defmodule AppWeb.SuperuserController do
  use AppWeb, :controller

  alias App.Accounts

  def index(conn, _params) do
    case get_session(conn, :is_superuser) do
      true ->
        users = Accounts.list_users()
        true_netid = get_session(conn, :true_uid)
        render(conn, "index.html", users: users, true_netid: true_netid)
      false -> render_error(conn, "forbidden")
      end
  end

  def switch(conn, %{"net_id" => net_id}) do
    case get_session(conn, :is_superuser) do
      true ->
        message = case net_id == get_session(conn, :true_uid) do
                    true -> "You are no longer impersonating another user"
                    false -> "You are now impersonating " <> net_id
                  end
        conn
        |> put_flash(:success, message)
        |> put_session(:uid, net_id)
        |> redirect(to: "/")

      false -> render_error(conn, "forbidden")
      end
  end
end
