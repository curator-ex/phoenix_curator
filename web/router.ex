defmodule PhoenixCurator.Router do
  use PhoenixCurator.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug Curator.Plug.LoadSession

    # Insert other Curator Plugs as necessary:
    plug CuratorConfirmable.Plug

    plug Curator.Plug.EnsureResourceOrNoSession, handler: PhoenixCurator.ErrorHandler
  end

  pipeline :authenticated_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug Curator.Plug.LoadSession

    # Insert other Curator Plugs as necessary:
    plug CuratorConfirmable.Plug

    plug Curator.Plug.EnsureResourceAndSession, handler: PhoenixCurator.ErrorHandler
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhoenixCurator do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    # CuratorDatabaseAuthenticatable
    get "/sessions", SessionController, :new
    post "/sessions", SessionController, :create
    delete "/sessions", SessionController, :delete

    # CuratorRegisterable
    resources "/registrations", RegistrationController, only: [:new, :create]
    get "/registrations/edit", RegistrationController, :edit
    get "/registrations", RegistrationController, :show
    put "/registrations", RegistrationController, :update, as: nil
    patch "/registrations", RegistrationController, :update
    delete "/registrations", RegistrationController, :delete

    # CuratorConfirmable
    resources "/confirmations", ConfirmationController, only: [:new, :create, :edit]
  end

  scope "/", PhoenixCurator do
    pipe_through :authenticated_browser # Use the default browser stack

    get "/secret", PageController, :secret
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhoenixCurator do
  #   pipe_through :api
  # end
end
