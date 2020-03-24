defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :store_path_in_session
    plug AppWeb.Plug.SetCurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug AppWeb.Plug.Auth
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
      resources "/comments", CommentController, except: [:index, :show, :new]
      resources "/ratings", RatingController, except: [:index, :show, :new, :edit]
    end


    resources "/users", UserController, only: [:edit, :show, :update]
    resources "/topics", TopicController, only: [:edit, :show, :update, :delete]
    resources "/submissions", SubmissionController, only: [:edit, :show, :update, :delete]
    resources "/comments", CommentController, only: [:edit, :update, :delete]
    resources "/ratings", RatingController, only: [:edit, :update, :delete]

    get "/superuser", SuperuserController, :index
    get "/superuser/switch", SuperuserController, :switch
  end


  # Other scopes may use custom stacks.
  # scope "/api", AppWeb do
  #   pipe_through :api
  # end
end
