defmodule AppWeb.ControllerHelpers do
  require Decimal
  use Phoenix.HTML
  import Plug.Conn
  import Phoenix.Controller

  def render_error(conn, message) do
    case String.downcase(message) do
      "forbidden" ->
        conn
        |> put_status(:forbidden)
        |> put_view(AppWeb.ErrorView)
        |> render("403.html")
      "not found" ->
        conn
        |> put_status(:not_found)
        |> put_view(AppWeb.ErrorView)
        |> render("404.html")
      _ ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: AppWeb.Router.Helpers.page_path(conn, :index))
      end
  end


end
