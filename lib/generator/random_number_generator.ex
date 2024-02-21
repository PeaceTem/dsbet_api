defmodule DSBet.RandomGenerator do
  # import Decimal

  @spec get(integer()) :: any()
  def get(current_value), do: random_number(current_value)


  defp random_number(current_value) do
    # Enum.random(0..9) * NaiveDateTime.now()
    # rem(Enum.random(0..9) * rem(:os.system_time(:millisecond), 10), 10)

    # Decimal.new
    # Decimal.new(Enum.random(-10000..10000))
    cond do
      current_value > 0 -> Enum.random(-current_value..current_value)
      current_value < 0 -> Enum.random(current_value..-current_value)
      current_value == 0 -> Enum.random(-10..10)
    end
  end
end
