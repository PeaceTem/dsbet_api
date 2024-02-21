defmodule DSBet.Tracker.Value do
  use Ecto.Schema
  import Ecto.Changeset

  schema "values" do
    field :value, :float

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(value, attrs) do
    value
    |> cast(attrs, [:value])
    |> validate_required([:value])
  end
end
