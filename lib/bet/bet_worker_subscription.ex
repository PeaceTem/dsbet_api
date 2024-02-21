defmodule DSBet.Bet.BetWorkerSubscription do
  def subscribe(id) do
    Phoenix.PubSub.subscribe(DSBet.PubSub, "bet-worker-#{id}")
    IO.puts("Subscription Done!")
  end

  def unsubscribe(id) do
    Phoenix.PubSub.unsubscribe(DSBet.PubSub, "bet-worker-#{id}")
  end
end
