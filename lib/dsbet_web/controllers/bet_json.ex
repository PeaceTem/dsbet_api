defmodule DSBetWeb.BetJSON do
  alias DSBet.Game.Bet

  @doc """
  Renders a list of bets.
  """
  def index(%{bets: bets}) do
    %{data: for(bet <- bets, do: data(bet))}
  end

  @doc """
  Renders a single bet.
  """
  def show(%{bet: bet}) do
    %{data: data(bet)}
  end

  defp data(%Bet{} = bet) do
    %{
      id: bet.id,
      start_value: bet.start_value,
      end_value: bet.end_value,
      stake: bet.stake,
      duration: bet.duration
    }
  end

  # Open price vs close price of the rate
  # You open a bet at a specific price for a specific period of time which has been predetermined
end
