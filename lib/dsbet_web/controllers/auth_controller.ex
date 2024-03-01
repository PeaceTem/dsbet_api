defmodule DSBetWeb.AuthController do
  use DSBetWeb, :controller
  plug Ueberauth


  alias DSBet.Accounts.User
  alias DSBet.Repo


  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    IO.inspect(auth)
    user_params = %{token: auth.credentials.token, email: auth.info.email, provider: "google"}
    changeset = User.google_changeset(%User{}, user_params)
    IO.inspect(%{changeset: changeset})
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
          DSBet.Accounts.create_user_with_changeset(changeset)
        user ->
          ensure_wallet(user)
      end
  end

  defp ensure_wallet(user) do
    wallet = DSBet.Wallets.get_wallet(user.id)
    if wallet do
      {:ok, user}
    else
      DSBet.Wallets.create_user_wallet(%{balance: 100, user_id: user.id})
      {:ok, user}
    end
  end

  @spec signout(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "Logged out successfully!")
    |> redirect(to: "/")
  end
 end
