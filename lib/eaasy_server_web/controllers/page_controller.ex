defmodule EaasyServerWeb.PageController do
  use EaasyServerWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end
end
