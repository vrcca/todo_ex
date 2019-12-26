import Config

http_port = String.to_integer(System.fetch_env!("HTTP_PORT"))

config :todo_ex, db_folder: "./persist"
config :todo_ex, http_port: http_port
