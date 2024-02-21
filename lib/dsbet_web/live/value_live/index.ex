defmodule DSBetWeb.ValueLive.Index do
  use DSBetWeb, :live_view

  alias DSBet.Tracker
  alias DSBet.Tracker.Value
  alias DSBet.Value.Subscription
  alias DSBet.Accounts
  alias DSBet.Game
  alias DSBet.Game.Bet
  alias DSBet.Bet.BetWorkerSubscription


  # def render(assigns) do
  #   DSBetWeb.LayoutView.render("index.html.heex", assigns, layout: false)
  # end


  @impl true
  def mount(_params, session, socket) do
  # def mount(_params, session, socket) do
    # IO.inspect(session["user_id"])

    updated_socket = socket
      |> assign(:user_id, session["user_id"] || 1)


    if connected?(socket), do: Subscription.subscribe()

    # IO.inspect(%{user_id: updated_socket.assigns.user_id})
    # do stream insert after a bet has been closed
    {:ok, stream(updated_socket, :bets, Game.list_user_bets(updated_socket.assigns.user_id))}
  end



  @impl true
  def handle_params(params, _url, socket) do
    changeset = Game.change_bet(%Bet{})

    socket = socket
    |> assign(:timer, 30)
    |> assign(:display_value, DSBet.ValueTracker.get_value())
    # |> assign(:user_id, user_id)
    |> assign(:time_remaining, 30)
    |> assign_form(changeset)
    |> assign(:form_is_not_valid, true)

    Process.send_after(self(), :connected, 100)
    _user = Accounts.get_user!(1)
    last_bet = Game.last_bet()
    IO.puts("Gotten to the first place!")
    IO.inspect(%{end_value: last_bet.end_value, null: is_nil(last_bet.end_value)})

    if is_nil(last_bet.end_value), do: BetWorkerSubscription.subscribe(last_bet.id)


    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end



  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Value")
    |> assign(:value, Tracker.get_value!(id))
  end



  defp apply_action(socket, :new, _params) do
    Process.send_after(self(), :connected, 100)
    socket
    |> assign(:page_title, "New Value")
    |> assign(:value, %Value{})

  end



  defp apply_action(socket, :index, _params) do
    if connected?(socket), do: DSBet.Timer.Subscription.subscribe()

    socket
    |> assign(:page_title, "Ta Tete Ko J'ere!")
    |> assign(:bet, nil)
    # |> assign(:bet, %Bet{})

  end



  @impl true
  def handle_info({DSBetWeb.ValueLive.FormComponent, {:saved, value}}, socket) do
    {:noreply, stream_insert(socket, :values, value)}
  end


  @impl true
  def handle_info({:bet_finalised, bet}, socket) do
    Process.send(self(), :connected, [])
    {:noreply, stream_insert(socket, :bets, bet, at: 0)}
  end


  @impl true
  def handle_info(:connected, socket) do
    # {:noreply, update(socket, :display_value, fn _ -> new_value end)}
    {:noreply, push_event(socket, "socket-connected", %{value_list: DSBet.ValueTracker.get_all_values()})}
  end



  @impl true
  def handle_info({:value_updated, new_value}, socket) do
    # {:noreply, update(socket, :display_value, fn _ -> new_value end)}
    # updated_socket = socket
    # |> assign(:display_value, new_value)

    # {:noreply, updated_socket}
    {:noreply, push_event(socket, "chart-updated", %{last_value: new_value})}
  end



  # decrement the timer, update the difference, finalise the bet when the timer is on zero
  @impl true
  def handle_info(:time_updated, socket) do
    # {:noreply, update(socket, :timer, fn time_value -> time_value - 1 end)}
    case socket.assigns.timer do
      1 -> DSBet.Timer.Subscription.unsubscribe()
      _ -> nil
    end
    new_time = max(0, socket.assigns.timer - 1)
    updated_socket = put_in(socket.assigns[:timer], new_time)
    {:noreply, push_event(updated_socket, "time-updated", %{current_time: new_time})}
  end



  @impl true
  def handle_info(:tick, socket) when socket.assigns.time_remaining > 0 do

    new_time_remaining = socket.assigns.time_remaining - 1

    if new_time_remaining > 5 do
      Process.send_after(self(), :tick, 1000)
    end

    updated_socket = put_in(socket.assigns[:time_remaining], new_time_remaining)
    IO.inspect(new_time_remaining)

    {:noreply, push_event(updated_socket, "time_remaining-updated", %{time_remaining: new_time_remaining})}
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, socket}
  end



  @impl true
  def handle_info({:bet_state, %{
    start_value: start_value,
    duration_left: duration_left,
    diff: diff,
    }}, socket) do



      # push an event for bet lost and won too

      {:noreply, push_event(
        socket,
        "bet_state-updated", %{
        start_value: start_value,
        duration_left: duration_left,
        diff: diff,
        }
        )
      }
  end






  @impl true
  def handle_event("start_timer", _unsigned_params, socket) do
    Process.send(self(), :tick, [])
    {:noreply, socket}
  end

  @impl true
  @spec handle_event(<<_::48>>, map(), Phoenix.LiveView.Socket.t()) :: {:noreply, map()}
  def handle_event("delete", %{"id" => id}, socket) do
    value = Tracker.get_value!(id)
    {:ok, _} = Tracker.delete_value(value)

    {:noreply, stream_delete(socket, :values, value)}
  end


  @impl true
  def handle_event("validate_bet", %{"bet" => bet_params}, socket) do
    # validate the stake(check if it is less than the wallet balance)
    # disable the submit bet button until all the entries are validated
    # re validate during submit bet event
    IO.inspect(%{bet_params: bet_params})

    changeset =
      %Bet{user_id: 1}
      |> Game.validate_bet(bet_params)
      |> Map.put(:action, :validate)

    IO.inspect(%{changeset: changeset})
    IO.inspect(%{not_valid: !changeset.valid?})


    Process.send(self(), :connected, [])


    {:noreply,socket
      |> assign_form(changeset)
      |> assign(:form_is_not_valid, !changeset.valid?)}
  end



  @impl true
  # def handle_event("bet_submitted", %{"start_value" => open_price, "duration" => duration, "tank" => tank, "stake" => stake}, socket) do
  # def handle_event("bet_submitted", %{"bet" => bet_params}, socket) do
  def handle_event("bet_submitted", params, socket) do
    IO.inspect(%{params: params["bet"]})

    # IO.inspect(%{submitted_bet_params: bet_params})
  # # # def handle_event("bet_submitted",_, socket) do


  #   # duration = 100
  #   # tank = true
  #   # stake = 100
  #   # bet_params = %{start_value: open_price, duration: duration, tank: tank, stake: stake, user_id: socket.assigns.user_id}
  #   # bet_params = %{start_value: open_price, duration: duration, tank: tank, stake: stake, user_id: 1}

    bet_attrs = params["bet"]
      |> Map.put("user_id", 1)
      |> Map.put("start_value", DSBet.ValueTracker.get_value())

    IO.inspect(%{bet_attrs: bet_attrs})

    {:ok, bet} = DSBet.Game.create_bet(bet_attrs)

    IO.inspect(bet)
    Phoenix.PubSub.subscribe(DSBet.PubSub, "bet-worker-#{bet.id}")
    # start the dynamic supervisor here (Take the logic out of this socket)
    # whenever a socket is mounted
    # check if the user is authenticated
    # and check for the user's active bet
    # listen to the pubsub echo coming from the process created to handle the bet
    DSBet.Bet.Utils.start_bet_worker(%{id: bet.id, name: :"bet-worker-#{bet.id}"})
    IO.puts("Gotten to the worker")
    {:noreply, socket}
  end



  # defp authenticated?(assigns) do
  #   assigns[:user_id] != nil
  # end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :bet_form, to_form(changeset))
  end

end
