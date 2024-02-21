defmodule DSBet.Timer.Subscription do
  def subscribe() do
    Phoenix.PubSub.subscribe(DSBet.PubSub, "timer")
  end

  def unsubscribe() do
    Phoenix.PubSub.unsubscribe(DSBet.PubSub, "timer")
  end
end
