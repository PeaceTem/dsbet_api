defmodule DSBet.RandomGenerator do
  # import Decimal

  @spec get(integer()) :: any()
  def get(current_value), do: generate_randint(current_value)

  # defp random_number(current_value) do
  #   # Enum.random(0..9) * NaiveDateTime.now()
  #   # rem(Enum.random(0..9) * rem(:os.system_time(:millisecond), 10), 10)

  #   # Decimal.new
  #   # Decimal.new(Enum.random(-10000..10000))
  #   cond do
  #     current_value > 0 -> Enum.random(-current_value..current_value)
  #     current_value < 0 -> Enum.random(current_value..-current_value)
  #     current_value == 0 -> Enum.random(-10..10)
  #   end
  # end

  defp generate_randint(current_value) do
    lower_bound = current_value - Enum.random(1..10)
    upper_bound = current_value + Enum.random(1..10)
    Enum.random(lower_bound..upper_bound)
  end
end
