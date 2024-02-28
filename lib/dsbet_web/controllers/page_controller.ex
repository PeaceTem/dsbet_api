defmodule DSBetWeb.PageController do
  use DSBetWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def login(conn, _params) do
    if conn.assigns[:user] do
      # route to the home page
      conn
      |> redirect(to: "/")
    else
      conn
        |> assign(:page_title, "Login | Pachinko")
        |> render(:login, layout: false)
    end
  end


  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "Logged out successfully!")
    |> redirect(to: "/")
  end


end
