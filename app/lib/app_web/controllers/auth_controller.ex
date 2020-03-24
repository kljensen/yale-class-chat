defmodule AppWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """

  use AppWeb, :controller
  plug Ueberauth

  alias Floki

  Plug.Conn

  def login(conn, _params, _current_user, _claims) do
    conn
    |> Ueberauth.Strategy.CAS.handle_request!
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: %{uid: uid}}} = conn, _params) do
    {:ok, _user} = App.Accounts.create_user_on_login(uid)

    conn
    |> clear_flash()
    |> put_flash(:success, "Successfully authenticated.")
    |> put_session(:uid, uid)
    |> redirect(to: "/")
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "You have been logged out!")
    |> redirect(to: "/")
  end


end
