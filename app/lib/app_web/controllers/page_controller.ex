defmodule AppWeb.PageController do
  use AppWeb, :controller

  def index(conn, _params) do
    uid = get_session(conn, :uid)
    net_id = uid
    #current_user = if !is_nil(uid) do
    #                  App.Accounts.get_user_by!(uid)
    #                end
    #net_id = if !is_nil(uid) do
    #            current_user.net_id
    #          end
    render(conn, "index.html", current_user: net_id)
  end
end
