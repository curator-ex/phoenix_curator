defmodule PhoenixCurator.RegistrationControllerTest do
  use PhoenixCurator.ConnCase

  alias PhoenixCurator.User

  @valid_attrs %{
    email: "user@test.com",
    password: "some content",
  }
  @invalid_attrs %{email: "fake_email"}

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
    conn = get conn, registration_path(conn, :new)

    assert html_response(conn, 200) =~ "New Account"
  end

  test "redirects when signed in for new resources", %{authorized_conn: conn} do
    conn = get conn, registration_path(conn, :new)

    assert Phoenix.Controller.get_flash(conn, :danger) == "Already Logged In"
    assert Phoenix.ConnTest.redirected_to(conn) == page_path(conn, :index)
  end

  # CREATE
  test "creates resource and redirects when data is valid", %{unauthenticated_conn: conn} do
    conn = post conn, registration_path(conn, :create), user: @valid_attrs

    assert Phoenix.Controller.get_flash(conn, :info) == "Account was successfully created. Check your email for a confirmation link."
    assert redirected_to(conn) == "/"
    assert Repo.get_by(User, email: @valid_attrs.email)
  end

  test "redirects when signed in when data is valid", %{authorized_conn: conn} do
    conn = post conn, registration_path(conn, :create), user: @valid_attrs

    assert Phoenix.Controller.get_flash(conn, :danger) == "Already Logged In"
    assert Phoenix.ConnTest.redirected_to(conn) == page_path(conn, :index)
  end

  test "does not create resource and renders errors when data is invalid", %{unauthenticated_conn: conn} do
    conn = post conn, registration_path(conn, :create), user: @invalid_attrs

    assert html_response(conn, 200) =~ "New Account"
  end

  # EDIT
  test "renders form for editing User", %{authorized_conn: conn} do
    conn = get conn, registration_path(conn, :edit)

    assert html_response(conn, 200) =~ "Edit Account"
  end

  test "doesn't render form for editing user (of unauthenticated user)", %{unauthenticated_conn: conn} do
    conn = get conn, registration_path(conn, :edit)

    assert Phoenix.Controller.get_flash(conn, :danger) == "Please Log In"
    assert Phoenix.ConnTest.redirected_to(conn) == session_path(conn, :new)
  end

  # UPDATE
  test "updates user and redirects when data is valid", %{authorized_conn: conn} do
    conn = patch conn, registration_path(conn, :update), user: @valid_attrs

    assert Phoenix.Controller.get_flash(conn, :info) == "Account updated successfully."
    assert redirected_to(conn) == registration_path(conn, :show)
  end

  test "doesn't update user (of unauthenticated user)", %{unauthenticated_conn: conn} do
    conn = patch conn, registration_path(conn, :update), user: @valid_attrs

    assert Phoenix.Controller.get_flash(conn, :danger) == "Please Log In"
    assert Phoenix.ConnTest.redirected_to(conn) == session_path(conn, :new)
  end

  # DELETE
  test "deletes user", %{authorized_conn: conn, authorized_user: user} do
    conn = delete conn, registration_path(conn, :delete)

    assert Phoenix.Controller.get_flash(conn, :info) == "Account deleted successfully."
    assert redirected_to(conn) == page_path(conn, :index)
    refute Repo.get(User, user.id)
  end

  test "doesn't delete user (of unauthenticated user)", %{unauthenticated_conn: conn} do
    conn = delete conn, registration_path(conn, :delete)

    assert Phoenix.Controller.get_flash(conn, :danger) == "Please Log In"
    assert Phoenix.ConnTest.redirected_to(conn) == session_path(conn, :new)
  end
end
