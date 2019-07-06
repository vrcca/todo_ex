defmodule TodoEx.Database do
  use GenServer

  @default_num_workers 5
  @default_db_folder "./persist"

  def start_link(opts \\ %{}) do
    opts = set_defaults(opts)
    GenServer.start(__MODULE__, opts, name: __MODULE__)
  end

  defp set_defaults(opts) do
    num_workers = Map.get(opts, :num_workers, @default_num_workers)
    db_folder = Map.get(opts, :db_folder, @default_db_folder)

    opts
    |> Map.put(:num_workers, num_workers)
    |> Map.put(:db_folder, db_folder)
  end

  @impl GenServer
  def init(opts = %{num_workers: num_workers, db_folder: db_folder})
      when is_number(num_workers) do
    File.mkdir_p!(db_folder)
    {:ok, opts, {:continue, :start_workers}}
  end

  @impl GenServer
  def handle_continue(:start_workers, state = %{num_workers: num_workers, db_folder: db_folder}) do
    workers =
      Enum.into(0..num_workers, %{}, fn index ->
        {:ok, worker} = TodoEx.DatabaseWorker.start(db_folder: db_folder)
        {index, worker}
      end)

    new_state = Map.put(state, :workers, workers)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_call(request = {:get, key}, _from, state = %{workers: workers}) do
    result =
      choose_worker(workers, key)
      |> GenServer.call(request)

    {:reply, result, state}
  end

  @impl GenServer
  def handle_cast(request = {:store, key, _data}, state = %{workers: workers}) do
    choose_worker(workers, key)
    |> GenServer.cast(request)

    {:noreply, state}
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  defp choose_worker(workers, key) do
    index = :erlang.phash2(key, 3)
    Map.get(workers, index)
  end
end
