defmodule PhoenixCurator.SessionController do
  use PhoenixCurator.Web, :controller

  plug Curator.Plug.EnsureNotAuthenticated, %{ handler: PhoenixCurator.ErrorHandler } when action in [:new, :create]
  plug Curator.Plug.EnsureAuthenticated, %{ handler: PhoenixCurator.ErrorHandler } when action in [:delete]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => session_params}) do
    case CuratorDatabaseAuthenticatable.authenticate(session_params) do
      {:ok, user} ->
        case Curator.before_sign_in(user) do
          :ok ->
            conn
            |> put_flash(:info, "Logged in.")
            |> Curator.PlugHelper.sign_in(user)
            |> Curator.after_sign_in(user)
            |> redirect(to: "/")
          {:error, error} ->
            conn
            |> put_flash(:danger, error)
            |> render("new.html")
        end
      {:error, user, _errors} ->
        conn
        |> Curator.after_failed_sign_in(user)
        |> put_flash(:danger, "Login Error")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> Curator.PlugHelper.sign_out
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/")
  end
end
