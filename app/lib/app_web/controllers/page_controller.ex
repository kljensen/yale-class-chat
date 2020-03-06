defmodule AppWeb.PageController do
  use AppWeb, :controller

  def index(conn, _params) do
    uid = get_session(conn, :uid)
    current_user = if !is_nil(uid) do
                      net_id = uid
                      App.Accounts.get_user_by!(net_id)
                    else
                      nil
                    end
    is_faculty = if !is_nil(uid) do
                    current_user.is_faculty
                  else
                    false
                  end
    #current_user = if !is_nil(uid) do
    #                  App.Accounts.get_user_by!(uid)
    #                end
    #net_id = if !is_nil(uid) do
    #            current_user.net_id
    #          end
    render(conn, "index.html", [current_user: current_user, is_faculty: is_faculty])
  end
end
