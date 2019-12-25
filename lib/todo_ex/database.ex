defmodule TodoEx.Database do
  require Logger

  @default_num_workers 5
  @default_db_folder Application.fetch_env!(:todo_ex, :db_folder)

  def child_spec(_opts) do
    root_folder = storage_dir(@default_db_folder)
    File.mkdir_p!(root_folder)

    poolboy_opts = [
      name: {:local, __MODULE__},
      worker_module: TodoEx.DatabaseWorker,
      size: @default_num_workers
    ]

    workers_opts = %{db_folder: root_folder}
    :poolboy.child_spec(__MODULE__, poolboy_opts, workers_opts)
  end

  # CLIENT API
  def store(key, data) do
    {_results, bad_nodes} =
      :rpc.multicall(__MODULE__, :store_local, [key, data], :timer.seconds(5))

    Enum.each(bad_nodes, &IO.puts("Store failed on node #{&1}"))
    :ok
  end

  def store_local(key, data) do
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

  # HELPERS
  defp storage_dir(root_folder) do
    Path.join(root_folder, node_name())
  end

  defp node_name() do
    node()
    |> Atom.to_string()
    |> String.split("@")
    |> case do
      ["nonode", _rest] -> "default"
      [name, _rest] -> name
    end
  end
end
