defmodule DSBet.Repo.Migrations.CreateValues do
  use Ecto.Migration

  def change do
    create table(:values) do
      add :value, :float

      timestamps(type: :utc_datetime)
    end
  end
end
