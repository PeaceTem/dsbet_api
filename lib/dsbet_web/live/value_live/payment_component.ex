defmodule DSBetWeb.ValueLive.PaymentComponent do
  use DSBetWeb, :live_component

  alias DSBet.Wallets
  # alias DSBet.Game

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Enter your Credit/Debit Card details.</:subtitle>
      </.header>

      <.simple_form
        for={@payment_form}
        id="payment-form"
        phx-target={@myself}

        phx-submit="save"
      >
        <.input cls_attr="text-red-900" field={@payment_form[:name]} type="text" label="Name"/>
        <div class="flex justify-between align-center">
          <.input cls_attr="flex-grow text-red-900" field={@payment_form[:card_number]} type="number" min="1" label="Card Number"/>
          <.input cls_attr="text-red-900" field={@payment_form[:amount]} type="number" min="100" max="10000" label="Amount"/>
        </div>
        <div class="flex justify-between align-center">
        <.input cls_attr="text-red-900" field={@payment_form[:expiry_month]} type="number" min="01" max="12" label="Expiry Month"/>
        <.input cls_attr="text-red-900" field={@payment_form[:expiry_year]} type="number" min="2024" max="2030" label="Expiry Year"/>
        <.input cls_attr="text-red-900" field={@payment_form[:cvv]} type="number" min="100" max="999" label="CVV"/>
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Fund Wallet</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    # Process.send_after(DSBetWeb.ValueLive.Index, :connected, 1000)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_payment_form()
    }
  end

  # @impl true
  # def handle_event("validate", %{"value" => value_params}, socket) do
  #   changeset =
  #     socket.assigns.value
  #     |> Tracker.change_value(value_params)
  #     |> Map.put(:action, :validate)

  #   {:noreply, assign_form(socket, changeset)}
  # end


  @impl true
  def handle_event("save", value_params, socket) do
    save_value(socket, socket.assigns.action, value_params)
  end

  defp save_value(socket, :pay, value_params) do

    wallet = Wallets.get_user_wallet(socket.assigns.user_id)
    {:ok, _w} = Wallets.update_wallet_balance(wallet, %{balance: Decimal.add(Decimal.new("#{value_params["amount"]}"), wallet.balance)})

    {:noreply,
     socket
     |> put_flash(:info, "Funded wallet successfully!")
     |> push_patch(to: socket.assigns.patch)}
  end


  defp assign_payment_form(socket) do
    assign(socket, :payment_form, to_form(%{
      "name" => "",
      "card_number" => "",
      "cvv" => "",
      "expiry_month" => "",
      "expiry_year" => "",
      "amount" => "",
    }))
  end
end
