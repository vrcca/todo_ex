defmodule TodoEx.Database do
  require Logger

  @default_num_workers 5
  @default_db_folder Application.fetch_env!(:todo_ex, :db_folder)

  def child_spec(_opts) do
    File.mkdir_p!(@default_db_folder)

    poolboy_opts = [
      name: {:local, __MODULE__},
      worker_module: TodoEx.DatabaseWorker,
      size: @default_num_workers
    ]

    workers_opts = %{db_folder: @default_db_folder}
    :poolboy.child_spec(__MODULE__, poolboy_opts, workers_opts)
  end

  # CLIENT API
  def store(key, data) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        TodoEx.DatabaseWorker.store(worker_pid, key, data)
      end
    )
  end

  def get(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        TodoEx.DatabaseWorker.get(worker_pid, key)
      end
    )
  end
end
