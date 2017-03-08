defmodule PhoenixCurator.ConfirmationControllerTest do
  use PhoenixCurator.ConnCase

  alias PhoenixCurator.User

  setup do
    conn_with_session = build_conn()
    |> conn_with_fetched_session

    user_attrs = %{
      email: "test_user_2@example.com",
    }
    unconfirmed_user = PhoenixCurator.User.changeset(%PhoenixCurator.User{}, user_attrs)
      |> PhoenixCurator.User.password_changeset(%{password: "TEST_PASSWORD", password_confirmation: "TEST_PASSWORD"})
      |> PhoenixCurator.Repo.insert!

    authorized_user = create_active_user
    authorized_conn = PhoenixCurator.SessionHelper.sign_in(conn_with_session, authorized_user)

    {:ok,
      unconfirmed_user: unconfirmed_user,
      unauthenticated_conn: conn_with_session,
      authorized_user: authorized_user,
      authorized_conn: authorized_conn,
    }
  end

  # NEW
  test "renders form for new resources", %{unauthenticated_conn: conn} do
    conn = get conn, confirmation_path(conn, :new)

    assert html_response(conn, 200) =~ "Confirm Account"
  end

  test "renders form for new resources (when signed in)", %{authorized_conn: conn} do
    conn = get conn, confirmation_path(conn, :new)

    assert html_response(conn, 200) =~ "Confirm Account"
  end

  # CREATE
  test "sends an email and redirects when data is valid", %{unauthenticated_conn: conn, unconfirmed_user: user} do
    conn = post conn, confirmation_path(conn, :create), %{confirmation: %{email: user.email}}

    assert Phoenix.Controller.get_flash(conn, :info) == "Confirmation email sent."
    assert redirected_to(conn) == "/"

    user = Repo.get!(User, user.id)
    refute user.confirmed_at
    assert user.confirmation_token
    assert user.confirmation_sent_at
  end

  test "shows the same info when the email is invalid", %{unauthenticated_conn: conn, unconfirmed_user: user} do
    conn = post conn, confirmation_path(conn, :create), %{confirmation: %{email: user.email <> "X"}}

    assert Phoenix.Controller.get_flash(conn, :info) == "Confirmation email sent."
    assert redirected_to(conn) == "/"
  end

  test "does not send an email when data is invalid", %{unauthenticated_conn: conn}  do
    conn = post conn, confirmation_path(conn, :create), %{confirmation: %{email: ""}}
    assert html_response(conn, 200) =~ "Confirm Account"
  end

  # EDIT
  test "confirms the user and redirects when token is valid", %{unauthenticated_conn: conn, unconfirmed_user: user} do
    confirmation_token = Curator.Token.generate
    confirmation_sent_at = Timex.now

    _user = Ecto.Changeset.change(user, confirmation_token: confirmation_token, confirmation_sent_at: confirmation_sent_at)
    |> PhoenixCurator.Repo.update!

    conn = get conn, confirmation_path(conn, :edit, confirmation_token)

    assert Phoenix.Controller.get_flash(conn, :info) == "Account confirmed."
    assert redirected_to(conn) == "/"

    user = Repo.get!(User, user.id)
    assert user.confirmed_at
    refute user.confirmation_token
    refute user.confirmation_sent_at
  end

  test "doesn't confirm the user when the token is incorrect", %{unauthenticated_conn: conn, unconfirmed_user: user} do
    confirmation_token = Curator.Token.generate
    confirmation_sent_at = Timex.now

    _user = Ecto.Changeset.change(user, confirmation_token: confirmation_token, confirmation_sent_at: confirmation_sent_at)
    |> PhoenixCurator.Repo.update!

    conn = get conn, confirmation_path(conn, :edit, confirmation_token <> "X")

    assert Phoenix.Controller.get_flash(conn, :danger) == "Invalid confirmation token."
    assert Phoenix.ConnTest.redirected_to(conn) == "/"
  end

  test "doesn't confirm the user when the token is expired", %{unauthenticated_conn: conn, unconfirmed_user: user} do
    confirmation_token = Curator.Token.generate
    confirmation_sent_at = Timex.now
    |> Curator.Time.unshift(CuratorConfirmable.Config.token_expiration)
    |> Timex.Ecto.DateTime.cast!

    _user = Ecto.Changeset.change(user, confirmation_token: confirmation_token, confirmation_sent_at: confirmation_sent_at)
    |> PhoenixCurator.Repo.update!

    conn = get conn, confirmation_path(conn, :edit, confirmation_token)

    assert Phoenix.Controller.get_flash(conn, :danger) == "Confirmation token expired."
    assert Phoenix.ConnTest.redirected_to(conn) == "/"
  end
end
