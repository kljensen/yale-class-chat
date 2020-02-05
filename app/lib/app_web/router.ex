defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug AppWeb.Plug.Auth
  end

  scope "/auth", AppWeb do
    pipe_through [:browser]

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    delete "/:provider/logout", AuthController, :delete
    get "/:provider/logout", AuthController, :delete
  end

  scope "/", AppWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/secret", AppWeb do
    pipe_through [:browser, :auth]

    get "/", SecretController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", AppWeb do
  #   pipe_through :api
  # end
end