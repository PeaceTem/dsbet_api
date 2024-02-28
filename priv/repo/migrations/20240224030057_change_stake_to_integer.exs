defmodule DSBet.Repo.Migrations.ChangeStakeToInteger do
  use Ecto.Migration

  def change do
    alter table(:bets) do
      modify :stake, :integer, default: 100
    end
  end
end
