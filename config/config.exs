use Mix.Config

config :todo_ex, db_folder: "./persist"
config :todo_ex, http_port: 5454

import_config "#{Mix.env()}.exs"
