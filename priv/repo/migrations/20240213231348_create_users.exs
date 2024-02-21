defmodule DSBet.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :token, :string
      add :username, :string
      add :provider, :string
      add :email, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:token])
  end
end
