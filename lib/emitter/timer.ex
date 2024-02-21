defmodule DSBet.Emitter.Timer do
  use GenServer


  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
  defp schedule_count do
    Process.send_after(self(), :count_time, 1000)
  end

  # Server Functions
  @impl true
  def init(_) do
    schedule_count()
    {:ok, System.os_time(:second)}
  end

  @impl true
  def handle_info(:count_time, state) do
    Phoenix.PubSub.broadcast(DSBet.PubSub, "timer", :time_updated)
    schedule_count()
    {:noreply, state}
  end
end
