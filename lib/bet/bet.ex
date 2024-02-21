defmodule DSBet.Bet.Bet do
  def start_worker(id) do
    DSBet.Bet.Worker.start_link(%{id: id, name: :"#{id}"}) #name can't be an atom
  end
end


# defmodule DSBet.BetTask do
#   use Task

#   # alias DSBet.Game
#   # the arg is the id of the bet
#   # store each value to the database, a range of values with be gotten to display the chart of each bet
#   def start_link(arg) do
#     Task.start_link(__MODULE__, :run, [arg])
#   end

#   # def run(arg) do
#   #   bet = Game.get_bet!(arg) # utc_datetime
#   #   case (bet.insert_at + bet.duration) > NaiveDateTime.now() do
#   #     true -> :do_something

#   #     false -> :do_nothing
#   #   end
#   #   # shutdown(self())
#   # end

#   def carry_out_task(bet) do
#     _duration_left = bet.duration
#     DSBet.Timer.Subscription.subscribe()

#   end

#   # def handle_info(:time_updated, socket) do

#   # end

# end


# # state = %{duration_left: duration, diff: current_value - start_value, close: false, bet_id: bet.id, }
# # Objectives
# # the duration left should be sent to the user
# # the difference between the start_value and current_value should be sent to the user
# # if the bet is won the user's wallet should be topped with the times 2 of betting stake
# # the start_value of the bet should be displayed on the user's screen
# # the current_value should be displayed on the user's screen
# # arrow-up and color green should be displayed to the user if winning
# # arrow-down and color red should be displayed to the user if losing
# # retain the state of each bet whenever the user refreshes the screen
# # each value should be stored in the database (the time should be assigned to the value from the genserver)

# # create a resolution function that checks for all active bets by the time the system restarts, and
# # do the due diligence


# # use mnesia to store active bets, delete them when you're done.
# #



# # check how to shutdown a genserver
