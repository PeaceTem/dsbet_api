defmodule DSBet.Game.Bet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bets" do
    field :start_value, :float
    field :end_value, :float
    field :stake, :integer
    field :duration, :integer
    field :tank, :boolean
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bet, attrs) do
    bet
    |> cast(attrs, [:start_value, :stake, :tank, :duration, :user_id])
    |> validate_required([:start_value, :stake, :tank, :duration, :user_id])
  end

  @doc false
  def update_end_value_changeset(bet, attr) do
    bet
    |> cast(attr, [:end_value])
    |> validate_required([:end_value])
  end


  @doc false
  def validate_bet_changeset(bet, attr) do
    bet
    |> cast(attr,[:stake, :duration, :user_id])
    |> validate_required([:stake, :duration, :user_id])
  end
end
