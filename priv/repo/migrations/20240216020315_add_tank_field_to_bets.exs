defmodule DSBet.Repo.Migrations.AddTankFieldToBets do
  use Ecto.Migration

  def change do
    alter table(:bets) do
      add(:tank, :boolean, default: false)
    end
  end
end
