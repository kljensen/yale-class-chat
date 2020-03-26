defmodule AppWeb.Errors do
    @moduledoc """
    Here we're implementing a custom errors so that we
    can raise them, generally from LiveViews. See 
    the discussion in the following two threads:

    * https://elixirforum.com/t/rendering-404s-through-liveview/30018/5
    * https://github.com/phoenixframework/phoenix_live_view/issues/641
    * https://hexdocs.pm/phoenix/errors.html
    """
  defmodule NotFound do
    defexception plug_status: 404, message: "no route found", conn: nil, router: nil
  end

  defmodule NotAuthorized do
    defexception plug_status: 401, message: "not authorized", conn: nil, router: nil
  end

  defmodule Forbidden do
    defexception plug_status: 403, message: "forbidden", conn: nil, router: nil
  end
end