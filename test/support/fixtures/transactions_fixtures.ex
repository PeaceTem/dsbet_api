defmodule DSBet.TransactionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DSBet.Transactions` context.
  """

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        amount: "120.5",
        details: "some details"
      })
      |> DSBet.Transactions.create_transaction()

    transaction
  end
end
