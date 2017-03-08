use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :phoenix_curator, PhoenixCurator.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :phoenix_curator, PhoenixCurator.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "",
  database: "phoenix_curator_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :curator, Curator,
  hooks_module: PhoenixCurator.CuratorHooks,
  repo: PhoenixCurator.Repo,
  user_schema: PhoenixCurator.User,
  session_handler: Curator.SessionHandlers.Guardian

config :guardian, Guardian,
  issuer: "phoenix_curator",
  ttl: { 1, :days },
  verify_issuer: true,
  secret_key: "vif3wei5ba7loetoh3vooB3ieX1oht",
  serializer: Curator.UserSerializer

config :phoenix_curator, PhoenixCurator.Mailer,
  adapter: Bamboo.LocalAdapter
