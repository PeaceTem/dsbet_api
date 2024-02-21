defmodule DSBet.Plugs.SetUser do
  import Plug.Conn
  # import Phoenix.Controller

  alias DSBet.Repo
  # alias CostmapWeb.User
  alias DSBet.Accounts.User

  def init(_params) do

  end

#   def init(opts), do: opts

  def call(conn, _params)  do
      user_id = get_session(conn, :user_id) #get user_id from the session
      IO.inspect(user_id)

      cond do
          user = user_id && Repo.get(User, user_id) -> #check if user exists in database and assign to user variable
              assign(conn, :user, user) #now assign user struct to the conn object
          true ->
              assign(conn, :user, nil)  #user not found in database, return nil, and conn object is un-changed.
      end
  end
end
