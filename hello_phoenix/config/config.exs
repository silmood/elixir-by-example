# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :hello_phoenix,
  ecto_repos: [HelloPhoenix.Repo]

# Configures the endpoint
config :hello_phoenix, HelloPhoenixWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "OLxkexNq/SKO6CByKzqoaPffozg+delpRXOFPePtwTE7YolxqKELbc+K9W2v4hmI",
  render_errors: [view: HelloPhoenixWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: HelloPhoenix.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
