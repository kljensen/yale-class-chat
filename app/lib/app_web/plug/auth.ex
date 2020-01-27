defmodule AppWeb.Plug.Auth do

  import Plug.Conn
  import Phoenix.Controller
  require Logger

  def init(_opts) do
  end

  def call(%{private: %{plug_session: %{current_user: uid}}} = conn, _options) do
    case uid do
      nil ->
        Logger.info ":: User is not logged in ::: "
        conn
        |> put_flash(:error, "You need to sign in or sign up before continuing.")
        |> redirect(to: "/auth/cas")
        |> halt()
      _ ->
        conn
        |> put_flash(:ok, "You are sign on")
    end
  end

  def call(conn, _params) do
    Logger.info ":: User is not logged in ::: "
    conn
    |> put_flash(:error, "You need to sign in or sign up before continuing.")
    |> redirect(to: "/auth/cas")
    |> halt()
  end



end
