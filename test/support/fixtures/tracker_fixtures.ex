defmodule DSBet.TrackerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DSBet.Tracker` context.
  """

  @doc """
  Generate a value.
  """
  def value_fixture(attrs \\ %{}) do
    {:ok, value} =
      attrs
      |> Enum.into(%{
        value: 120.5
      })
      |> DSBet.Tracker.create_value()

    value
  end
end
