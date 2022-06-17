defmodule StamprWeb.PageController do
  use StamprWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
