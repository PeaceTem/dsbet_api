defmodule DSBet.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :amount, :decimal
      add :details, :string
      add :wallet_id, references(:wallets, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:transactions, [:wallet_id])
  end
end
