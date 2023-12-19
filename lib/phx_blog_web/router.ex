defmodule PhxBlogWeb.Router do
  use PhxBlogWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug PhxBlog.Accounts.Pipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/api", PhxBlogWeb do
    pipe_through [:api, :auth]

    post "/users", UserController, :create
    patch "/users/:id", UserController, :update
    post "/login", SessionController, :login
    get "/check-email", UserController, :check_email
  end

  scope "/api", PhxBlogWeb do
    pipe_through [:api, :auth, :ensure_auth]

    get "/logout", SessionController, :logout
    resources "/users", UserController, except: [:create]
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:phx_blog, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: PhxBlogWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
