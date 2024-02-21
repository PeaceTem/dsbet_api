defmodule DSBetWeb.BetControllerTest do
  use DSBetWeb.ConnCase

  import DSBet.GameFixtures

  alias DSBet.Game.Bet

  @create_attrs %{
    start_value: 120.5,
    end_value: 120.5,
    stake: 120.5,
    duration: 42
  }
  @update_attrs %{
    start_value: 456.7,
    end_value: 456.7,
    stake: 456.7,
    duration: 43
  }
  @invalid_attrs %{start_value: nil, end_value: nil, stake: nil, duration: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all bets", %{conn: conn} do
      conn = get(conn, ~p"/api/bets")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create bet" do
    test "renders bet when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/bets", bet: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/bets/#{id}")

      assert %{
               "id" => ^id,
               "duration" => 42,
               "end_value" => 120.5,
               "stake" => 120.5,
               "start_value" => 120.5
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/bets", bet: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update bet" do
    setup [:create_bet]

    test "renders bet when data is valid", %{conn: conn, bet: %Bet{id: id} = bet} do
      conn = put(conn, ~p"/api/bets/#{bet}", bet: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/bets/#{id}")

      assert %{
               "id" => ^id,
               "duration" => 43,
               "end_value" => 456.7,
               "stake" => 456.7,
               "start_value" => 456.7
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, bet: bet} do
      conn = put(conn, ~p"/api/bets/#{bet}", bet: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete bet" do
    setup [:create_bet]

    test "deletes chosen bet", %{conn: conn, bet: bet} do
      conn = delete(conn, ~p"/api/bets/#{bet}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/bets/#{bet}")
      end
    end
  end

  defp create_bet(_) do
    bet = bet_fixture()
    %{bet: bet}
  end
end
