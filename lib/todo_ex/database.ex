defmodule TodoEx.Database do
  use GenServer

  @default_num_workers 5
  @default_db_folder "./persist"

  def start_link(opts \\ %{}) do
    opts = set_defaults(opts)
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  defp set_defaults(opts) do
    num_workers = Map.get(opts, :num_workers, @default_num_workers)
    db_folder = Map.get(opts, :db_folder, @default_db_folder)

    opts
    |> Map.put(:num_workers, num_workers)
    |> Map.put(:db_folder, db_folder)
  end

  @impl GenServer
  def init(opts = %{num_workers: num_workers})
      when is_number(num_workers) do
    IO.puts("Starting database server.")
    {:ok, opts, {:continue, :start_workers}}
  end

  @impl GenServer
  def handle_continue(:start_workers, state = %{num_workers: num_workers, db_folder: db_folder}) do
    File.mkdir_p!(db_folder)

    Enum.each(0..num_workers, fn index ->
      {:ok, _pid} = TodoEx.DatabaseWorker.start_link(%{id: index, db_folder: db_folder})
    end)

    {:noreply, state}
  end

  @impl GenServer
  def handle_call(
        {:choose_worker, key},
        _from,
        state = %{num_workers: num_workers}
      ) do
    worker_id = :erlang.phash2(key, num_workers)
    {:reply, worker_id, state}
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> TodoEx.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> TodoEx.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key})
  end
end
