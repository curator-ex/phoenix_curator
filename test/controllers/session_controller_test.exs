defmodule PhoenixCurator.SessionControllerTest do
  use PhoenixCurator.ConnCase

  alias PhoenixCurator.User

  # NOTE: This data is taken from PhoenixCurator.SessionHelper.create_active_user
  @valid_attrs %{email: "test_user@example.com", password: "TEST_PASSWORD"}

  setup do
    conn_with_session = build_conn()
    |> conn_with_fetched_session

    authorized_user = create_active_user
    authorized_conn = PhoenixCurator.SessionHelper.sign_in(conn_with_session, authorized_user)

    {:ok,
      authorized_user: authorized_user,
      unauthenticated_conn: conn_with_session,
      authorized_conn: authorized_conn,
    }
  end

  # NEW
  test "renders form for new resources", %{unauthenticated_conn: conn} do
    conn = get conn, session_path(conn, :new)

    assert html_response(conn, 200) =~ "Login"
  end

  test "redirects when signed in for new resources", %{authorized_conn: conn} do
    conn = get conn, session_path(conn, :new)

    assert Phoenix.Controller.get_flash(conn, :danger) == "Already Logged In"
    assert Phoenix.ConnTest.redirected_to(conn) == page_path(conn, :index)
  end

  # CREATE
  test "creates resource and redirects when data is valid", %{unauthenticated_conn: conn} do
    conn = post conn, session_path(conn, :create), session: @valid_attrs

    assert Phoenix.Controller.get_flash(conn, :info) == "Logged in."
    assert redirected_to(conn) == "/"
    assert Repo.get_by(User, email: @valid_attrs.email)
  end

  test "redirects when signed in when data is valid", %{authorized_conn: conn} do
    conn = post conn, session_path(conn, :create), session: @valid_attrs

    assert Phoenix.Controller.get_flash(conn, :danger) == "Already Logged In"
    assert Phoenix.ConnTest.redirected_to(conn) == page_path(conn, :index)
  end

  test "does not create resource and renders errors when password is invalid", %{unauthenticated_conn: conn, authorized_user: authorized_user} do
    conn = post conn, session_path(conn, :create), session: %{@valid_attrs | password: "ERROR" }

    assert Phoenix.Controller.get_flash(conn, :danger) == "Login Error"
    assert html_response(conn, 200) =~ "Login"
  end

  # test "does not create resource and increment failed_attempts when password is invalid", %{unauthenticated_conn: conn, authorized_user: authorized_user} do
  #   conn = post conn, session_path(conn, :create), session: %{@valid_attrs | password: "ERROR" }

  #   assert authorized_user.failed_attempts == 0

  #   assert Phoenix.Controller.get_flash(conn, :danger) == "Login Error"
  #   assert html_response(conn, 200) =~ "Login"

  #   user = PhoenixCurator.Repo.get(User, authorized_user.id)
  #   assert user.failed_attempts == 1
  # end

  test "does not create resource and renders errors when email is invalid", %{unauthenticated_conn: conn} do
    conn = post conn, session_path(conn, :create), session: %{@valid_attrs | email: "error@example.com" }

    assert Phoenix.Controller.get_flash(conn, :danger) == "Login Error"
    assert html_response(conn, 200) =~ "Login"
  end

  # test "does not create resource and renders errors when user is unconfirmed", %{unauthenticated_conn: conn, authorized_user: user} do
  #   Ecto.Changeset.change(user, confirmed_at: nil)
  #   |> PhoenixCurator.Repo.update!

  #   conn = post conn, session_path(conn, :create), session: @valid_attrs

  #   assert Phoenix.Controller.get_flash(conn, :danger) == "Not Confirmed"
  #   assert html_response(conn, 200) =~ "Login"
  # end

  # test "does not create resource and renders errors when user is unapproved", %{unauthenticated_conn: conn, authorized_user: user} do
  #   Ecto.Changeset.change(user, approval_status: "pending")
  #   |> PhoenixCurator.Repo.update!

  #   conn = post conn, session_path(conn, :create), session: @valid_attrs

  #   assert Phoenix.Controller.get_flash(conn, :danger) == "Not Approved"
  #   assert html_response(conn, 200) =~ "Login"
  # end

  # test "does not create resource and renders errors when user is locked", %{unauthenticated_conn: conn, authorized_user: user} do
  #   Ecto.Changeset.change(user, locked_at: Timex.now)
  #   |> PhoenixCurator.Repo.update!

  #   conn = post conn, session_path(conn, :create), session: @valid_attrs

  #   assert Phoenix.Controller.get_flash(conn, :danger) == "Account Locked"
  #   assert html_response(conn, 200) =~ "Login"
  # end

  # DELETE
  test "deletes user", %{authorized_conn: conn} do
    conn = delete conn, session_path(conn, :delete)

    assert Phoenix.Controller.get_flash(conn, :info) == "Logged out successfully."
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "doesn't delete user (of unauthenticated user)", %{unauthenticated_conn: conn} do
    conn = delete conn, session_path(conn, :delete)

    assert Phoenix.Controller.get_flash(conn, :danger) == "Please Log In"
    assert Phoenix.ConnTest.redirected_to(conn) == session_path(conn, :new)
  end
end
