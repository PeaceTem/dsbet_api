defmodule DSBetWeb.Router do
  use DSBetWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DSBetWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end


  pipeline :require_authenticated_user do
    # remove this plug after it has been tested
    plug DSBet.Plugs.SetUser #our module plug is added onto list of plugs. notice the all above are function plugs.
    plug DSBet.Plugs.RequireAuth
  end

  scope "/", DSBetWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/", ValueLive.Index, :index
    live "/values/new", ValueLive.Index, :new
    live "/pay", ValueLive.Index, :pay
    live "/withdraw", ValueLive.Index, :withdraw
  end

  scope "/", DSBetWeb do
    pipe_through :browser

    get "/login", PageController, :login
  end


  scope "/api", DSBetWeb do
    pipe_through :api
    resources "/bets", BetController, except: [:new, :edit]
  end

  def swagger_info do
    %{
      basePath: "/api",
      info: %{
        version: "1.0",
        title: "My App"
      },
      tags: [%{name: "Users", description: "Operations about Users"}]
    }
  end

  scope "/api/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :dsbet, swagger_file: "swagger.json"
  end


  scope "/auth", DSBetWeb do
    pipe_through :browser
    # go to costmap and fetch the :browser atom properties
    # auth
    get "/signout", AuthController, :signout
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback

  end

  # Other scopes may use custom stacks.
  # scope "/api", DSBetWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:dsbet, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DSBetWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
