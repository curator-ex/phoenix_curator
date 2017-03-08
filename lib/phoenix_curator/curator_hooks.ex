defmodule PhoenixCurator.CuratorHooks do
  use PhoenixCurator.Web, :controller
  use Curator.Hooks

  def before_sign_in(user, type) do
    with :ok <- CuratorConfirmable.Hooks.before_sign_in(user, type) do
      :ok
    end
  end

  def after_extension(conn, :registration, user) do
    conn
    |> put_flash(:info, "Account was successfully created. Check your email for a confirmation link.")
    |> send_email(:confirmation, user)
    |> redirect(to: "/")
  end

  def after_extension(conn, :confirmation, _user) do
    conn
    |> put_flash(:info, "Account confirmed.")
    |> redirect(to: "/")
  end

  def send_email(conn, :confirmation, user) do
    {user, token} = CuratorConfirmable.set_confirmation_token!(user)

    url = confirmation_url(conn, :edit, token)

    PhoenixCurator.Email.confirmation_email(user, url)
    |> PhoenixCurator.Mailer.deliver_now

    conn
  end
end
