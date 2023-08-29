defmodule QuebradoBankWeb.Router do
  use QuebradoBankWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug QuebradoBankWeb.Plugs.Auth
  end

  scope "/api", QuebradoBankWeb do
    pipe_through :api

    post "/users", UsersController, :create
    post "/users/login", UsersController, :login
  end

  scope "/api", QuebradoBankWeb do
    pipe_through [:api, :auth]

    resources "/users", UsersController, only: [:update, :delete, :show]

    post "/accounts", AccountsController, :create
    post "/accounts/transaction", AccountsController, :transaction
    post "/accounts/withdraw", AccountsController, :withdraw
    post "/accounts/deposit", AccountsController, :deposit
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:quebrado_bank, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: QuebradoBankWeb.Telemetry
    end
  end
end
