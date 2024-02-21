defmodule DSBet.GameFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DSBet.Game` context.
  """

  @doc """
  Generate a bet.
  """
  def bet_fixture(attrs \\ %{}) do
    {:ok, bet} =
      attrs
      |> Enum.into(%{
        duration: 42,
        end_value: 120.5,
        stake: 120.5,
        start_value: 120.5
      })
      |> DSBet.Game.create_bet()

    bet
  end
end
