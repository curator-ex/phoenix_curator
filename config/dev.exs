use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :phoenix_curator, PhoenixCurator.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                    cd: Path.expand("../", __DIR__)]]


# Watch static and templates for browser reloading.
config :phoenix_curator, PhoenixCurator.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :phoenix_curator, PhoenixCurator.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "",
  database: "phoenix_curator_dev",
  hostname: "localhost",
  pool_size: 10

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
