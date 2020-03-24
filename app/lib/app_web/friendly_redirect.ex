defmodule AppWeb.FriendlyRedirect do
  import Plug.Conn

  def store_path_in_session(conn, _) do
    # Get HTTP method and url from conn
    method = conn.method
    path = conn.request_path

    # If conditions apply store path in session, else return conn unmodified
    case {method, storable?(path)} do
      {"GET", true} ->
        put_session(conn, :friendly_redirect_path, path)

      {_, _} ->
        conn
    end
  end

  defp storable?(path) do
    !(String.match?(path, ~r/auth|user/))
  end

  def target_path(conn) do
    target_path =
      get_session(conn, :friendly_redirect_path) ||
      default_retargeting_path()
  end

  defp default_retargeting_path() do
    "/"
  end
end
