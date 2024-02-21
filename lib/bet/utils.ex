defmodule DSBet.Bet.Utils do

  def start_bet_worker(opts) do
    {:ok, _bet_pid} = DynamicSupervisor.start_child(DSBet.BetSupervisor, {DSBet.Bet.Worker, %{name: opts.name, id: opts.id}})

  end
end
