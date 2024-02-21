defmodule DSBet.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DSBet.Accounts` context.
  """

  @doc """
  Generate a unique user email.
  """
  def unique_user_email, do: "some email#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique user token.
  """
  def unique_user_token, do: "some token#{System.unique_integer([:positive])}"

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: unique_user_email(),
        provider: "some provider",
        token: unique_user_token(),
        username: "some username"
      })
      |> DSBet.Accounts.create_user()

    user
  end
end
