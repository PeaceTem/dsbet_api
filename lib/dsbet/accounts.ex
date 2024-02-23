defmodule DSBet.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias DSBet.Repo

  alias DSBet.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  def insert_or_update_user(changeset) do
    Repo.insert_or_update(changeset)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.
  Creates a wallet and add a one-to-one relationship from the user to the wallet
  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    # create a wallet and for each user by default
    {:ok, user} = %User{}
    |> User.changeset(attrs)
    |> Repo.insert()

    DSBet.Wallets.create_user_wallet(%{balance: 100, user_id: user.id})
  end
  #DSBet.Wallets.create_user_wallet(%{balance: 100, user_id: 1})
  #DSBet.Accounts.get_user_wallet(1)
  #DSBet.Accounts.get_wallet_user(1)

  def get_wallet_user(user_id) do
    query = from w in DSBet.Wallets.Wallet,
      where: w.user_id == ^user_id,
      select: w
    Repo.one(query)
  end

  def get_user_wallet(user_id) do
    query = from u in User,
      where: u.id == ^user_id,
      select: u
    Repo.one(query)
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
