defmodule DSBetWeb.ValueLive.FormComponent do
  use DSBetWeb, :live_component

  alias DSBet.Tracker
  # alias DSBet.Game

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage value records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="value-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:value]} type="number" label="Value" step="any" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Value</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{value: value} = assigns, socket) do
    changeset = Tracker.change_value(value)
    # Process.send_after(DSBetWeb.ValueLive.Index, :connected, 1000)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"value" => value_params}, socket) do
    changeset =
      socket.assigns.value
      |> Tracker.change_value(value_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"value" => value_params}, socket) do
    save_value(socket, socket.assigns.action, value_params)
  end

  defp save_value(socket, :edit, value_params) do
    case Tracker.update_value(socket.assigns.value, value_params) do
      {:ok, value} ->
        notify_parent({:saved, value})

        {:noreply,
         socket
         |> put_flash(:info, "Value updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_value(socket, :new, value_params) do
    case Tracker.create_value(value_params) do
      {:ok, value} ->
        notify_parent({:saved, value})

        {:noreply,
         socket
         |> put_flash(:info, "Value created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
