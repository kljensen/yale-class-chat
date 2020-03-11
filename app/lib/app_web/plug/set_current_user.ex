defmodule AppWeb.Plug.SetCurrentUser do
  import Plug.Conn

  alias App.Repo
  alias App.Accounts

  def init(_params) do
  end

  def call(conn, _params) do
    uid = Plug.Conn.get_session(conn, :uid)
    cond do
      current_user = uid && App.Accounts.get_user_by!(uid) ->
        conn
        |> assign(:current_user, current_user)
        |> assign(:user_signed_in?, true)
      true ->
        conn
        |> assign(:current_user, nil)
        |> assign(:user_signed_in?, false)
    end
  end
end
