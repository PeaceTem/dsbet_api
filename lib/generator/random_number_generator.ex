defmodule DSBet.RandomGenerator do
  # import Decimal

  @spec get(integer()) :: any()
  def get(current_value), do: generate_randint(current_value)


  defp generate_randint(current_value) do
    lower_bound = current_value - Enum.random(1..5)
    upper_bound = current_value + Enum.random(1..5)
    Enum.random(lower_bound..upper_bound)
  end
end
