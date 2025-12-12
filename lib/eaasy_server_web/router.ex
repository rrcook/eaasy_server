defmodule EaasyServerWeb.Router do
  use EaasyServerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {EaasyServerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EaasyServerWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # GraphQL API
  scope "/api" do
    pipe_through :api

    forward "/graphql", Absinthe.Plug,
      schema: EaasyServerWeb.Schema,
      context: %{}

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: EaasyServerWeb.Schema,
      interface: :simple,
      context: %{}
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:eaasy_server, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: EaasyServerWeb.Telemetry
    end
  end
end
