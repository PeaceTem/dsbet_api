defmodule DSBet.Repo do
  use Ecto.Repo,
    otp_app: :dsbet,
    adapter: Ecto.Adapters.Postgres
end
