defmodule DSBetWeb.ValueLive.Index do
  use DSBetWeb, :live_view

  alias DSBet.Value.Subscription
  alias DSBet.Game
  alias DSBet.Game.Bet
  alias DSBet.Bet.BetWorkerSubscription
  alias DSBet.Wallets


  @impl true
  def mount(_params, session, socket) do

    updated_socket = socket
      |> assign(:user_id, session["user_id"])

    {:ok, stream(updated_socket, :bets, Game.list_user_bets(updated_socket.assigns.user_id))}
  end



  @impl true
  def handle_params(params, _url, socket) do
    user_id = socket.assigns.user_id

    wallet = Wallets.get_user_wallet(user_id)
    changeset = Game.change_bet(%Bet{})

    if connected?(socket), do: Subscription.subscribe()

    socket = socket
    |> assign(:display_value, DSBet.ValueTracker.get_value())
    |> assign_form(changeset)
    |> assign(:form_is_not_valid, false)
    |> assign(:balance, Decimal.to_string(wallet.balance))

    Process.send_after(self(), :connected, 100)


    last_bet = Game.last_bet(user_id)

    if !is_nil(last_bet) && is_nil(last_bet.end_value), do: BetWorkerSubscription.subscribe(last_bet.id)

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end


  defp apply_action(socket, :pay, _params) do
    Process.send_after(self(), :connected, 100)
    socket
    |> assign(:page_title, "Fund Wallet")
  end


  defp apply_action(socket, :withdraw, _params) do
    Process.send_after(self(), :connected, 100)
    socket
    |> assign(:page_title, "Withdraw Funds")
  end


  defp apply_action(socket, :index, _params) do

    socket
    |> assign(:page_title, "Ta Tete Ko J'ere!")
    |> assign(:bet, nil)

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
  def handle_info({:value_updated, {new_value, new_time}}, socket) do
    # update chart
    {:noreply, push_event(socket, "chart-updated", %{last_value: [new_value, new_time]})}
  end



  @impl true
  def handle_info({:bet_state, %{
    start_value: start_value,
    duration_left: duration_left,
    diff: diff,
    tank: tank,
    }}, socket) do



      # push an event for bet lost and won too

      {:noreply, push_event(
        socket,
        "bet_state-updated", %{
        start_value: start_value,
        duration_left: duration_left,
        diff: diff,
        tank: tank,
        }
        )
      }
  end


  @impl true
  def handle_info({:bet_won, balance}, socket) do

    Process.send(self(), :connected, [])
    {:noreply, socket
      |> put_flash(:info, "Bet won! You can still win more.")
      |> assign(:balance, Decimal.to_string(balance))}
  end



  @impl true
  def handle_info(:bet_lost, socket) do
    Process.send(self(), :connected, [])
    {:noreply, socket |> put_flash(:error, "Don't give up! Let him, who has not lost a game, be the first to cast a stone!")}
  end


  @impl true
  def handle_event("clear-flash", _, socket) do
    Process.send(self(), :connected, [])
    {:noreply, socket}
  end

  @impl true
  def handle_event("bet-price-up", params, socket) do
    IO.inspect(%{params: params})
    {:noreply, socket}
  end


  @impl true
  def handle_event("validate_bet", %{"bet" => bet_params}, socket) do
    IO.inspect(%{bet_params: bet_params})
    user_id = socket.assigns.user_id

    changeset =
      %Bet{user_id: user_id}
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
  def handle_event("bet_submitted", params, socket) do
    IO.inspect{%{bet_parameter: params}}
    IO.inspect(%{params: params["bet"]})


    user_id = socket.assigns.user_id
    wallet = Wallets.get_user_wallet(user_id)
    IO.inspect(%{wallet: wallet})

    bet_attrs = params["bet"]
      |> Map.put("user_id", user_id)
      |> Map.put("start_value", DSBet.ValueTracker.get_value())

    IO.inspect(%{stake: String.to_integer(bet_attrs["stake"])})
    integer_balance = Decimal.to_integer(wallet.balance)
    if Decimal.to_integer(wallet.balance) < String.to_integer(bet_attrs["stake"]) do
      IO.inspect(%{can_bet: "no"})
      {:noreply, socket
                  |> put_flash(:error, "Your Wallet balance is too low!")}
    else


      {:ok, bet} = DSBet.Game.create_bet(bet_attrs)

      Phoenix.PubSub.subscribe(DSBet.PubSub, "bet-worker-#{bet.id}")
      DSBet.Bet.Utils.start_bet_worker(%{id: bet.id, name: :"bet-worker-#{bet.id}"})
      # update the wallet by deducting the amount of naira staked from the wallet
      {:ok, updated_wallet} = Wallets.update_wallet_balance(wallet, %{balance: Decimal.new(integer_balance - bet.stake)})
      Process.send(self(), :connected, [])

      {:noreply, socket
                  |> put_flash(:info, "Bet started successfully!")
                  |> assign(:balance, Decimal.to_string(updated_wallet.balance))}
    end

  end



  # defp authenticated?(assigns) do
  #   assigns[:user_id] != nil
  # end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :bet_form, to_form(changeset))
  end


end
