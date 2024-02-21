defmodule DSBet.Wallets.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wallets" do
    field :balance, :decimal
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:balance, :user_id])
    |> validate_required([:balance, :user_id])
    |> unique_constraint(:user_id)
  end
end
