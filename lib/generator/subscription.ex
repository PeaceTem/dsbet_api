defmodule DSBet.Value.Subscription do
  def subscribe() do
    Phoenix.PubSub.subscribe(DSBet.PubSub, "value_tracker")
  end

  def unsubscribe() do
    Phoenix.PubSub.unsubscribe(DSBet.PubSub, "value_tracker")
  end
end
