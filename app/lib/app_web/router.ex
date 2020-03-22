defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug AppWeb.Plug.Auth
    plug AppWeb.Plug.SetCurrentUser
    plug AppWeb.Plug.AuthenticateUser
  end

  scope "/auth", AppWeb do
    pipe_through [:browser]

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    delete "/:provider/logout", AuthController, :delete
    get "/:provider/logout", AuthController, :delete
  end

  scope "/", AppWeb do
    pipe_through [:browser]

    get "/", PageController, :index
    get "/about", AboutController, :index
  end

  scope "/", AppWeb do
    pipe_through [:browser, :auth]

    #get "/", PageController, :index
    resources "/courses", CourseController do
      resources "/sections", SectionController, only: [:new]
      resources "/course_roles", Course_RoleController
      resources "/topics", TopicController, only: [:new, :create]
      get "/add_course_roles", Course_RoleController, :bulk_new
      post "/add_course_roles", Course_RoleController, :bulk_create
    end

    resources "/sections", SectionController, except: [:index, :new] do
      resources "/topics", TopicController, except: [:show, :new, :create, :index]
      get "/add_section_roles", Section_RoleController, :bulk_new
      post "/add_section_roles", Section_RoleController, :bulk_create
      get "/add_section_roles_api", Section_RoleController, :api_new
      post "/add_section_roles_api", Section_RoleController, :api_create
      resources "/section_roles", Section_RoleController
      delete "/leave_section", Section_RoleController, :self_delete
    end

    resources "/topics", TopicController, only: [:show] do
      resources "/submissions", SubmissionController, except: [:show, :index]
    end

    resources "/submissions", SubmissionController, only: [:show] do
      resources "/comments", CommentController, except: [:index]
      resources "/ratings", RatingController
    end


    resources "/users", UserController, only: [:edit, :show, :update]
    resources "/topics", TopicController, only: [:edit, :show, :update, :delete]
    resources "/submissions", SubmissionController, only: [:edit, :show, :update, :delete]
    resources "/comments", CommentController, only: [:edit, :show, :update, :delete]
    resources "/ratings", RatingController, only: [:edit, :show, :update, :delete]

    get "/mysections", UserSectionController, :index
  end


  # Other scopes may use custom stacks.
  # scope "/api", AppWeb do
  #   pipe_through :api
  # end
end
