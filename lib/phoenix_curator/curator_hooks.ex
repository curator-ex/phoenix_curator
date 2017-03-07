defmodule PhoenixCurator.CuratorHooks do
  use PhoenixCurator.Web, :controller
  use Curator.Hooks

  def after_extension(conn, :registration, user) do
    conn
    |> put_flash(:info, "Account was successfully created.")
    |> redirect(to: "/")
  end
end
