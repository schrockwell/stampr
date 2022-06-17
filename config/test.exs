import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :stampr, StamprWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "sXyQfxJ90jJI/C3KRSiSnLd6B5liwBUp0LA3m8P1bNszu84OlFUXmpXrNudj75L+",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
