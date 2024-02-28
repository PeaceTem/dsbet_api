defmodule DSBetWeb.AuthController do
  use DSBetWeb, :controller
  plug Ueberauth


  alias DSBet.Accounts.User
  alias DSBet.Repo


  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    IO.inspect(auth)
    user_params = %{token: auth.credentials.token, email: auth.info.email, provider: "google"}
    changeset = User.google_changeset(%User{}, user_params)

    signin(conn, changeset)
  end


  defp signin(conn, changeset) do
    IO.puts("Signing in!")
    case insert_or_update_user(changeset) do
        {:ok, user} ->
            conn
            |> put_flash(:info, "Welcome back")
            |> put_session(:user_id, user.id) # might not be needed; perhaps, you should just return a token for the user to store in his localhost
            |> redirect(to: "/")
        {:error, _reason} ->
            conn
            |> put_flash(:error, "error signing in")
            |> redirect(to: "/login")
    end
  end


  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do
        nil ->
          Repo.insert(changeset)
        user ->
          {:ok, user}
      end
  end



  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "Logged out successfully!")
    |> redirect(to: "/")
  end


  # def signout(conn, _params) do
  #   conn
  #   |> configure_session(drop: true) # use the logic for a rest api here
  #   # |> put_flash(:info, "Logged out successfully!")
  #   |> redirect(to: "/")
  # end

 end
