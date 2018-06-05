defmodule VuechatWeb.PageController do
  use VuechatWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
