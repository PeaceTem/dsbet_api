defmodule DSBet.WalletsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DSBet.Wallets` context.
  """

  @doc """
  Generate a wallet.
  """
  def wallet_fixture(attrs \\ %{}) do
    {:ok, wallet} =
      attrs
      |> Enum.into(%{
        balance: "120.5"
      })
      |> DSBet.Wallets.create_wallet()

    wallet
  end
end
