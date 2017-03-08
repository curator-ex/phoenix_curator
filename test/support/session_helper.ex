defmodule PhoenixCurator.SessionHelper do
  @default_opts [
    store: :cookie,
    key: "foobar",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt"
  ]

  @secret String.duplicate("abcdef0123456789", 8)
  @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))

  def conn_with_fetched_session(conn) do
    put_in(conn.secret_key_base, @secret)
    |> Plug.Session.call(@signing_opts)
    |> Plug.Conn.fetch_session
  end

  def sign_in(conn, resource, perms \\ %{perms: %{}}) do
    conn
    |> conn_with_fetched_session
    |> Curator.PlugHelper.sign_in(resource)
    |> Curator.after_sign_in(resource)
    |> Curator.Plug.LoadSession.call(%{})
  end

  @user_attrs %{
    email: "test_user@example.com",
  }

  def create_user(user, attrs) do
    user
    |> PhoenixCurator.User.changeset(attrs)
    |> PhoenixCurator.User.password_changeset(%{password: "TEST_PASSWORD", password_confirmation: "TEST_PASSWORD"})
    |> Ecto.Changeset.change(confirmed_at: Timex.now)
    # |> PhoenixCurator.User.approvable_changeset(%{approval_at: Timex.now, approval_status: "approved", approver_id: 0})
    |> PhoenixCurator.Repo.insert!
  end

  def create_active_user, do: create_user(%PhoenixCurator.User{}, @user_attrs)

  def sign_in_and_create_user(conn) do
    user = create_active_user
    conn = sign_in(conn, user)
    {conn, user}
  end
end
