defmodule DSBetWeb.BetController do
  use DSBetWeb, :controller

  alias DSBet.Game
  alias DSBet.Game.Bet

  action_fallback DSBetWeb.FallbackController

  def index(conn, _params) do
    bets = Game.list_bets()
    render(conn, :index, bets: bets)
  end

  def create(conn, %{"bet" => bet_params}) do
    with {:ok, %Bet{} = bet} <- Game.create_bet(bet_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/bets/#{bet}")
      |> render(:show, bet: bet)
    end
  end

  def show(conn, %{"id" => id}) do
    bet = Game.get_bet!(id)
    render(conn, :show, bet: bet)
  end

  def update(conn, %{"id" => id, "bet" => bet_params}) do
    bet = Game.get_bet!(id)

    with {:ok, %Bet{} = bet} <- Game.update_bet(bet, bet_params) do
      render(conn, :show, bet: bet)
    end
  end

  def delete(conn, %{"id" => id}) do
    bet = Game.get_bet!(id)

    with {:ok, %Bet{}} <- Game.delete_bet(bet) do
      send_resp(conn, :no_content, "")
    end
  end
end
