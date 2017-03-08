defmodule PhoenixCurator.PageControllerTest do
  use PhoenixCurator.ConnCase

  alias PhoenixCurator.User
  alias PhoenixCurator.Repo

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end

  @user_attrs %{
    email: "test_user@example.com",
  }

  describe "testing authentication" do
    setup do
      conn = Phoenix.ConnTest.build_conn()
      |> conn_with_fetched_session

      {:ok, conn: conn}
    end

    test "visiting a secret page w/o a user", %{conn: conn} do
      conn = get conn, "/secret"

      assert Phoenix.Controller.get_flash(conn, :danger) == "Please Log In"
      assert Phoenix.ConnTest.redirected_to(conn) == session_path(conn, :new)
    end

    test "visiting a secret page w/ a signed_in active user", %{conn: conn} do
      user = create_active_user

      conn = conn
      |> sign_in(user)
      |> get("/secret")

      assert html_response(conn, 200) =~ "Sneaky, Sneaky, Sneaky..."
    end

    test "visiting a secret page w/ a signed_in unconfirmed user", %{conn: conn} do
      user = User.changeset(%User{}, @user_attrs)
      |> User.password_changeset(%{password: "TEST_PASSWORD", password_confirmation: "TEST_PASSWORD"})
      #|> Ecto.Changeset.change(confirmed_at: Ecto.DateTime.utc)
      #|> User.approvable_changeset(%{approval_at: Ecto.DateTime.utc, approval_status: "approved", approver_id: 0})
      |> Repo.insert!

      conn = conn
      |> sign_in(user)
      |> get("/secret")

      assert Phoenix.Controller.get_flash(conn, :danger) == "Not Confirmed"
      assert Phoenix.ConnTest.redirected_to(conn) == session_path(conn, :new)
    end

    # test "visiting a secret page w/ a signed_in unapproved user", %{conn: conn} do
    #   user = User.changeset(%User{}, @user_attrs)
    #   |> User.password_changeset(%{password: "TEST_PASSWORD", password_confirmation: "TEST_PASSWORD"})
    #   |> Ecto.Changeset.change(confirmed_at: Timex.now)
    #   #|> User.approvable_changeset(%{approval_at: Ecto.DateTime.utc, approval_status: "approved", approver_id: 0})
    #   |> Repo.insert!

    #   conn = conn
    #   |> sign_in(user)
    #   |> get("/secret")

    #   assert Phoenix.Controller.get_flash(conn, :danger) == "Not Approved"
    #   assert Phoenix.ConnTest.redirected_to(conn) == session_path(conn, :new)
    # end

    # test "visiting a secret page w/ a signed_in (timed_out) active user", %{conn: conn} do
    #   user = create_active_user

    #   conn = conn
    #   |> sign_in(user)
    #   |> Plug.Conn.put_session(CuratorTimeoutable.Keys.timeoutable_key(:default), Curator.Time.timestamp() - CuratorTimeoutable.Config.timeout_in)
    #   |> get("/secret")

    #   assert Phoenix.Controller.get_flash(conn, :danger) == "Session Timeout"
    #   assert Phoenix.ConnTest.redirected_to(conn) == session_path(conn, :new)
    # end

    test "sign_in_and_create_user", %{conn: conn} do
      {conn, _user} = sign_in_and_create_user(conn)

      conn = conn
      |> get("/secret")

      assert html_response(conn, 200) =~ "Sneaky, Sneaky, Sneaky..."
    end
  end
end
