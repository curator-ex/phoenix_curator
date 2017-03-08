defmodule PhoenixCurator.ConfirmationController do
  use PhoenixCurator.Web, :controller

  alias PhoenixCurator.User

  plug CuratorConfirmable.VerifyToken, %{ handler: __MODULE__ } when action in [:edit]

  def new(conn, _params) do
    user = Curator.PlugHelper.current_resource(conn)
    data = case user do
      nil -> %{}
      %User{email: email} -> %{email: email}
    end

    changeset = CuratorConfirmable.request_confirmation_email_changeset(data)
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"confirmation" => %{"email" => email}}) do
    changeset = CuratorConfirmable.request_confirmation_email_changeset(%{email: email})

    if changeset.valid? do
      user = PhoenixCurator.Repo.get_by(User, email: email)

      if user do
        unless CuratorConfirmable.confirmed?(user) do
          PhoenixCurator.CuratorHooks.send_email(conn, :confirmation, user)
        end
      end

      conn
      |> put_flash(:info, "Confirmation email sent.")
      |> redirect(to: "/")
    else
      render(conn, "new.html", changeset: %{changeset | action: :create})
    end
  end

  def edit(conn, _params) do
    user = conn.private[:curator_confirmable_user]

    CuratorConfirmable.confirm!(user)

    conn
    |> Curator.after_extension(:confirmation, user)
  end

  def token_error(conn, :invalid) do
    conn
    |> put_flash(:danger, "Invalid confirmation token.")
    |> redirect(to: "/")
    |> halt
  end

  def token_error(conn, :expired) do
    conn
    |> put_flash(:danger, "Confirmation token expired.")
    |> redirect(to: "/")
    |> halt
  end
end
