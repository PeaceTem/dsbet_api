defmodule DSBet.Bet.Worker do
  use GenServer, restart: :temporary

  alias DSBet.Game
  alias DSBet.Value.Subscription
  # Client Functions
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts.id, name: opts.name)
  end



  # Server Functions
  @impl true
  def init(bet_id) do
    IO.inspect(info: bet_id)
    bet = Game.get_bet!(bet_id)

    Subscription.subscribe()
    Phoenix.PubSub.subscribe(DSBet.PubSub, "timer")

    {:ok, %{
      bet: bet,
      start_value: bet.start_value,
      end_value: bet.end_value,
      duration_left: bet.duration,
      diff: 0,
      tank: bet.tank,
      active: true,
      }}
  end



  @impl true
  def handle_info({:value_updated, new_value}, %{
    bet: bet,
    start_value: start_value,
    end_value: _end_value,
    duration_left: duration_left,
    diff: diff,
    tank: tank,
    active: active,
    }) do

    IO.inspect(info: "got the first info")

    if duration_left <= 0 do
      Subscription.unsubscribe()
      Phoenix.PubSub.unsubscribe(DSBet.PubSub, "timer")
      # broadcast game won and game lost info to the user too.
      Phoenix.PubSub.broadcast(
        DSBet.PubSub,
        "bet-worker-#{bet.id}",
        {:bet_state, %{
            start_value: start_value,
            duration_left: duration_left,
            diff: diff,
            tank: bet.tank,
        }})

    else
      Phoenix.PubSub.broadcast(
        DSBet.PubSub,
        "bet-worker-#{bet.id}",
        {:bet_state, %{
            start_value: start_value,
            duration_left: duration_left,
            diff: diff,
            tank: bet.tank,
        }})


    end
    {:noreply, %{
      bet: bet,
      start_value: start_value,
      end_value: new_value,
      duration_left: duration_left,
      diff: new_value - start_value,
      tank: tank,
      active: active,
      }}
  end




  @impl true
  def handle_info(:time_updated, %{
    bet: bet,
    start_value: start_value,
    end_value: end_value,
    duration_left: duration_left,
    diff: diff,
    tank: tank,
    active: active,
    }) do

    updated_duration_left = duration_left - 1

    case updated_duration_left do
      0 -> Process.send_after(self(), :finalise_bet, 100)
      _ -> nil
    end
    {:noreply, %{
      bet: bet,
      start_value: start_value,
      end_value: end_value,
      duration_left: updated_duration_left,
      diff: diff,
      tank: tank,
      active: active,
      }}
  end



  @impl true
  def handle_info(:finalise_bet, %{
    bet: bet,
    start_value: start_value,
    end_value: end_value,
    duration_left: duration_left,
    diff: diff,
    tank: tank,
    active: _active,
    }) do

    case tank do
      true -> bet_tanks(bet, diff)
      false -> bet_tanks_not(bet, diff)
    end

    {:ok, bet} = Game.update_end_value(bet,
      %{
        end_value: end_value
        })

    Phoenix.PubSub.broadcast(
      DSBet.PubSub,
      "bet-worker-#{bet.id}",
      {:bet_finalised, bet})

    # terminate the server here
    {:noreply, %{
      bet: bet,
      start_value: start_value,
      end_value: end_value,
      duration_left: duration_left,
      diff: diff,
      tank: bet.tank,
      active: false,
      }}
  end


  @impl true
  def handle_info(:kill_me_pls, state) do
    # GenServer.stop(self())
    # {:noreply, state}
    {:stop, :normal, state}
  end



  @impl true
  def terminate(_, _state) do
    IO.inspect "Look! I'm dead."
  end


  defp bet_tanks(bet, diff) do
    # if diff is < 0, bet won carry out the bet_won function
    # else, carry out the bet_lost function
    case diff < 0 do
      true -> bet_won(bet)
      false -> bet_lost(bet)
    end
  end

  defp bet_tanks_not(bet, diff) do
    # if diff is > 0, bet won carry out the bet_won function
    # else, carry out the bet_lost function
    case diff > 0 do
      true -> bet_won(bet)
      false -> bet_lost(bet)
    end
  end

  defp bet_won(bet) do
    IO.inspect(%{stake: bet.stake, money_won: bet.stake * 2 })
  end


  defp bet_lost(bet) do
    IO.inspect(%{stake: bet.stake, money_lost: bet.stake })
  end
  # def terminate(reason, state) do

  # end

end
