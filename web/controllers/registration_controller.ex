defmodule PhoenixCurator.RegistrationController do
  use PhoenixCurator.Web, :controller

  alias PhoenixCurator.User
  alias PhoenixCurator.Repo

  plug Curator.Plug.EnsureNotAuthenticated, %{ handler: PhoenixCurator.ErrorHandler } when action in [:new, :create]
  plug Curator.Plug.EnsureResourceAndSession, %{ handler: PhoenixCurator.ErrorHandler } when action in [:show, :edit, :update, :delete]

  def new(conn, _params) do
    changeset = User.create_registration_changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.create_registration_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> Curator.after_extension(:registration, user)
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, _params) do
    user = Curator.PlugHelper.current_resource(conn)

    render(conn, "show.html", user: user)
  end

  def edit(conn, _params) do
    user = Curator.PlugHelper.current_resource(conn)

    changeset = User.update_registration_changeset(user)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    user = Curator.PlugHelper.current_resource(conn)

    changeset = User.update_registration_changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Account updated successfully.")
        |> redirect(to: registration_path(conn, :show))
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    user = Curator.PlugHelper.current_resource(conn)

    Repo.delete!(user)

    conn
    |> put_flash(:info, "Account deleted successfully.")
    |> redirect(to: "/")
  end
end
