defmodule DSBet.ValueTracker do
  use GenServer

  require Logger

  # make the update_value function a server function
  # remove it from the client

  # Client Functions

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def update_value() do
    GenServer.cast(__MODULE__, :update_value)
  end

  def get_value do
    GenServer.call(__MODULE__, :get_value)
  end

  def get_all_values do
    GenServer.call(__MODULE__, :get_all_values)
  end

  defp schedule_work do
    Process.send_after(self(), :update_value, 1000) # In 1 second
  end

  # Server Functions
  @impl true
  def init(_) do
    schedule_work()
    # get the last value from the database
    {:ok, %{value_list: [0, Time.utc_now().second], value: 0}}
  end

  @impl true
  def handle_cast(:update_value, %{value_list: value_list, value: value}) do
    # value_gotten = DSBet.RandomGenerator.get(value)
    # new_value = value + value_gotten
    new_value = DSBet.RandomGenerator.get(value)
    new_time = Time.utc_now().second

    # IO.inspect(%{new_value: new_value})

    temp_list = value_list ++ [[new_value, new_time]]
    new_value_list = temp_list
      |> Enum.reverse()
      |> Enum.take(100)
      |> Enum.reverse()

    Phoenix.PubSub.broadcast(DSBet.PubSub, "value_tracker", {:value_updated, {new_value, new_time}})
    schedule_work()
    {:noreply, %{value_list: new_value_list, value: new_value, time: new_time}}
  end

  @impl true
  def handle_call(:get_value, _from, %{value_list: value_list, value: value}) do
    {:reply, value, %{value_list: value_list, value: value}}
  end

  @impl true
  def handle_call(:get_all_values, _from, %{value_list: value_list, value: value}) do
    {:reply, value_list, %{value_list: value_list, value: value}}
  end

  @impl true
  def handle_info(:update_value, state) do
    update_value()
    {:noreply, state}
  end
end
