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

  def convert_NYC_datetime_to_db(raw_input) do
    {:ok, output} = NaiveDateTime.new(String.to_integer(raw_input["year"]), String.to_integer(raw_input["month"]), String.to_integer(raw_input["day"]), String.to_integer(raw_input["hour"]), String.to_integer(raw_input["minute"]), 0)
    {:ok, output} = DateTime.from_naive(output, "America/New_York")
    {:ok, output} = DateTime.shift_zone(output, "Etc/UTC")
    output
  end

end
