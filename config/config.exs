# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.




# General application configuration
import Config

config :dsbet, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: DSBetWeb.Router,     # phoenix routes will be converted to swagger paths
      endpoint: DSBetWeb.Endpoint  # (optional) endpoint config used to set host, port and https schemes.
    ]
  }


  # If multiple swagger files need to be generated, add additional entries to the project config:
  # config :dsbet, :phoenix_swagger,
  # swagger_files: %{
  #   "booking-api.json" => [router: MyApp.BookingRouter],
  #   "reports-api.json" => [router: MyApp.ReportsRouter],
  #   "admin-api.json" => [router: MyApp.AdminRouter]
  # }

config :phoenix_swagger, json_library: Jason





# # Quantum Configuration
# config :dsbet, DSBet.Scheduler,
#   jobs: [
#     {"* * * *", {DSBet.ValueTracker, :update_value, []}},
#     # {"* * * *", {DSBet.Task, :perform, []}},
#   ]


# UeberAuth OAuth-2 Connfiguration

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, []}
  ]

# UeberAuth Google OAuth Configuration
config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")


config :dsbet,
  namespace: DSBet,
  ecto_repos: [DSBet.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :dsbet, DSBetWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: DSBetWeb.ErrorHTML, json: DSBetWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: DSBet.PubSub,
  live_view: [signing_salt: "VrCN4qEj"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :dsbet, DSBet.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
