defmodule DSBet.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :token, :string
    field :username, :string
    field :provider, :string
    field :email, :string
    
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:token, :username, :provider, :email])
    |> validate_required([:token, :username, :provider, :email])
    |> unique_constraint(:email)
    |> unique_constraint(:token)
  end

    @doc false
    def google_changeset(user, attrs) do
      user
      |> cast(attrs, [:token, :provider, :email])
      |> validate_required([:token, :provider, :email])
      |> unique_constraint(:email)
      |> unique_constraint(:token)
    end



end
