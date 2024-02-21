defmodule DSBet.Repo.Migrations.CreateBets do
  use Ecto.Migration

  def change do
    create table(:bets) do
      add :start_value, :float
      add :end_value, :float
      add :stake, :float
      add :duration, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:bets, [:user_id])
  end
end
