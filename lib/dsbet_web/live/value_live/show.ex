defmodule DSBetWeb.ValueLive.Show do
  use DSBetWeb, :live_view

  alias DSBet.Tracker

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:value, Tracker.get_value!(id))}
  end

  defp page_title(:show), do: "Show Value"
  defp page_title(:edit), do: "Edit Value"
end
