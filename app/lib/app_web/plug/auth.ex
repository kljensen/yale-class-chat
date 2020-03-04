defmodule AppWeb.Plug.Auth do

  import Plug.Conn
  import Phoenix.Controller
  require Logger

  def init(_opts) do
  end

  def call(%{private: %{plug_session: %{uid: uid}}} = conn, _options) do
    IO.inspect "Private function called"
    case uid do
      nil ->
        Logger.info ":: User is not logged in ::: "
        conn
        |> put_flash(:error, "You need to sign in or sign up before continuing.")
        |> redirect(to: "/auth/cas")
        |> halt()
      _ ->
        conn
        |> put_flash(:ok, "You are signed on")
    end
  end

  def call(conn, _params) do
    uid = get_session(conn, :uid)

    case uid do
      nil ->
        Logger.info ":: User is not logged in ::: "
        conn
        |> put_flash(:error, "You need to sign in or sign up before continuing.")
        |> redirect(to: "/auth/cas")
        |> halt()
      _ ->
        conn
        |> put_flash(:ok, "You are signed on")
    end

    #Logger.info ":: User is not logged in ::: "
    #conn
    #|> put_flash(:error, "You need to sign in or sign up before continuing.")
    #|> redirect(to: "/auth/cas")
    #|> halt()
  end



end
