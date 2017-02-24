defmodule PhoenixCurator.PageController do
  use PhoenixCurator.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
