defmodule DSBetWeb.ValueLive.WithdrawalComponent do
  use DSBetWeb, :live_component

  alias DSBet.Wallets

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Enter your Credit/Debit Card details.</:subtitle>
      </.header>

      <.simple_form
        for={@withdrawal_form}
        id="value-form"
        phx-target={@myself}
        phx-submit="save"
      >
        <.input cls_attr="text-red-900" field={@withdrawal_form[:amount]} type="number" label="Amount"/>
        <div class="flex justify-between align-center">
        <.input cls_attr="text-red-900" field={@withdrawal_form[:code]} type="number" min="0000" max="9999" label="Code"/>
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Withdraw</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do

    {:ok,
     socket
     |> assign(assigns)
     |> assign_withdrawal_form()
    }
  end

  # @impl true
  # def handle_event("validate", value_params, socket) do
  #   changeset =
  #     socket.assigns.value
  #     |> Map.put(:action, :validate)

  #   {:noreply, assign_form(so cket, changeset)}
  # end

  @impl true
  def handle_event("save", value_params, socket) do
    save_value(socket, socket.assigns.action, value_params)
  end

  defp save_value(socket, :withdraw, value_params) do
    IO.inspect(%{value_params: value_params})

    wallet = Wallets.get_user_wallet(socket.assigns.user_id)

    if Decimal.to_integer(wallet.balance) < String.to_integer(value_params["amount"]) do

      {:noreply,
      socket
      |> put_flash(:error, "Insufficient Balance!")
      |> push_patch(to: ~p"/withdraw")}

    else

      {:ok, _w} = Wallets.update_wallet_balance(wallet, %{balance: Decimal.sub(wallet.balance, Decimal.new("#{value_params["amount"]}"))})

      {:noreply,
      socket
      |> put_flash(:info, "Funds Withdrawn successfully!")
      |> push_patch(to: socket.assigns.patch)}

    end
  end

  defp assign_withdrawal_form(socket) do
    assign(socket, :withdrawal_form, to_form(%{
      "amount" => nil,
      "code" => nil,
      }))
  end

end
