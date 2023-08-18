defmodule BookclubWeb.PageController do
  use BookclubWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: "/meetings")
  end
end
