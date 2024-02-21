defmodule DSBet.GameTest do
  use DSBet.DataCase

  alias DSBet.Game

  describe "bets" do
    alias DSBet.Game.Bet

    import DSBet.GameFixtures

    @invalid_attrs %{start_value: nil, end_value: nil, stake: nil, duration: nil}

    test "list_bets/0 returns all bets" do
      bet = bet_fixture()
      assert Game.list_bets() == [bet]
    end

    test "get_bet!/1 returns the bet with given id" do
      bet = bet_fixture()
      assert Game.get_bet!(bet.id) == bet
    end

    test "create_bet/1 with valid data creates a bet" do
      valid_attrs = %{start_value: 120.5, end_value: 120.5, stake: 120.5, duration: 42}

      assert {:ok, %Bet{} = bet} = Game.create_bet(valid_attrs)
      assert bet.start_value == 120.5
      assert bet.end_value == 120.5
      assert bet.stake == 120.5
      assert bet.duration == 42
    end

    test "create_bet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_bet(@invalid_attrs)
    end

    test "update_bet/2 with valid data updates the bet" do
      bet = bet_fixture()
      update_attrs = %{start_value: 456.7, end_value: 456.7, stake: 456.7, duration: 43}

      assert {:ok, %Bet{} = bet} = Game.update_bet(bet, update_attrs)
      assert bet.start_value == 456.7
      assert bet.end_value == 456.7
      assert bet.stake == 456.7
      assert bet.duration == 43
    end

    test "update_bet/2 with invalid data returns error changeset" do
      bet = bet_fixture()
      assert {:error, %Ecto.Changeset{}} = Game.update_bet(bet, @invalid_attrs)
      assert bet == Game.get_bet!(bet.id)
    end

    test "delete_bet/1 deletes the bet" do
      bet = bet_fixture()
      assert {:ok, %Bet{}} = Game.delete_bet(bet)
      assert_raise Ecto.NoResultsError, fn -> Game.get_bet!(bet.id) end
    end

    test "change_bet/1 returns a bet changeset" do
      bet = bet_fixture()
      assert %Ecto.Changeset{} = Game.change_bet(bet)
    end
  end
end
