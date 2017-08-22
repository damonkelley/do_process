# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :do_process_web,
  namespace: DoProcessWeb

# Configures the endpoint
config :do_process_web, DoProcessWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4u1lPgSIlpkR0RBDFhtmOJ4lobygvUz5nnwQ4klgtLUq9Ze1HvYicNHIHH+sp1fo",
  render_errors: [view: DoProcessWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: DoProcessWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :do_process_web, :generators,
  context_app: :do_process

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
