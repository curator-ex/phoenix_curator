defmodule PhoenixCurator.ErrorHandler do
  use PhoenixCurator.Web, :controller

  @moduledoc """
  A default error handler that can be used for failed authentication
  """

  def unauthenticated(conn, %{reason: {:error, reason}}) do
    respond(conn, response_type(conn), 401, reason, session_path(conn, :new))
  end

  def unauthorized(conn, _params) do
    respond(conn, response_type(conn), 403, "Unauthorized", page_path(conn, :index))
  end

  def no_resource(conn, %{reason: reason}) do
    respond(conn, response_type(conn), 403, reason, session_path(conn, :new))
  end

  def already_authenticated(conn, _params) do
    respond(conn, response_type(conn), 302, "Already Logged In", page_path(conn, :index))
  end

  defp respond(conn, :json, status, msg, _path) do
    try do
      conn
      |> configure_session(drop: true)
      |> put_resp_content_type("application/json")
      |> send_resp(status, Poison.encode!(%{errors: [msg]}))
    rescue ArgumentError ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(status, Poison.encode!(%{errors: [msg]}))
    end
  end

  defp respond(conn, :html, _status, msg, path) do
    msg = translate_message(msg)

    conn
    |> clear_session
    |> put_flash(:danger, msg)
    |> redirect(to: path)
  end

  defp translate_message(:no_session) do
    "Please Log In"
  end

  defp translate_message(:no_resource) do
    "Please Log In"
  end

  defp translate_message(:token_expired) do
    "Please Log In"
  end

  defp translate_message(msg) when is_atom(msg) do
    raise "Please Translate #{msg}"
  end

  defp translate_message(msg) when is_binary(msg) do
    msg
  end

  defp response_type(conn) do
    accept = accept_header(conn)
    if Regex.match?(~r/json/, accept) do
      :json
    else
      :html
    end
  end

  defp accept_header(conn)  do
    value = conn
      |> get_req_header("accept")
      |> List.first

    value || ""
  end
end
