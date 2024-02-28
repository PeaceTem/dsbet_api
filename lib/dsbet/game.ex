defmodule DSBet.Game do
  @moduledoc """
  The Game context.
  """

  import Ecto.Query, warn: false
  alias DSBet.Repo

  alias DSBet.Game.Bet

  def last_bet(user_id) do
    query = from b in Bet,
      where: b.user_id == ^user_id,
      order_by: [desc: :id],
      select: b

    bets = Repo.all(query)
    Enum.at(bets, 0)
  end

  def list_user_bets(user_id) do
    query = from b in Bet,
      where: b.user_id == ^user_id,
      order_by: [desc: :id],
      select: b,
      limit: 10

    Repo.all(query)
  end


  @doc """
  Returns the list of bets.

  ## Examples

      iex> list_bets()
      [%Bet{}, ...]

  """
  def list_bets do
    Repo.all(Bet)
  end

  @doc """
  Gets a single bet.

  Raises `Ecto.NoResultsError` if the Bet does not exist.

  ## Examples

      iex> get_bet!(123)
      %Bet{}

      iex> get_bet!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bet!(id), do: Repo.get!(Bet, id)

  @doc """
  Creates a bet.

  ## Examples

      iex> create_bet(%{field: value})
      {:ok, %Bet{}}

      iex> create_bet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bet(attrs \\ %{}) do
    %Bet{}
    |> Bet.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bet.

  ## Examples

      iex> update_bet(bet, %{field: new_value})
      {:ok, %Bet{}}

      iex> update_bet(bet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bet(%Bet{} = bet, attrs) do
    bet
    |> Bet.changeset(attrs)
    |> Repo.update()
  end

  def update_end_value(%Bet{} = bet, attr) do
    bet
    |> Bet.update_end_value_changeset(attr)
    |> Repo.update()
  end

  @doc """
  Deletes a bet.

  ## Examples

      iex> delete_bet(bet)
      {:ok, %Bet{}}

      iex> delete_bet(bet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bet(%Bet{} = bet) do
    Repo.delete(bet)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bet changes.

  ## Examples

      iex> change_bet(bet)
      %Ecto.Changeset{data: %Bet{}}

  """
  def change_bet(%Bet{} = bet, attrs \\ %{}) do
    Bet.changeset(bet, attrs)
  end

  def validate_bet(%Bet{} = bet, attrs \\ %{}) do
    Bet.validate_bet_changeset(bet, attrs)
  end
end
