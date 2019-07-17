defmodule TodoEx.Database do

  @default_num_workers 5
  @default_db_folder "./persist"

  def start_link(opts \\ %{}) do
    opts = set_defaults(opts)
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(%{db_folder: db_folder}) do
    IO.puts("Starting database server.")
    File.mkdir_p!(db_folder)

    children = Enum.map(0..@default_num_workers, fn id -> worker_spec(id, db_folder) end)
    Supervisor.init(children, strategy: :one_for_one)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :supervisor
    }
  end

  defp set_defaults(opts) do
    db_folder = Map.get(opts, :db_folder, @default_db_folder)

    opts
    |> Map.put(:db_folder, db_folder)
  end

  defp worker_spec(id, db_folder) do
    default_worker_spec = {TodoEx.DatabaseWorker, %{id: id, db_folder: db_folder}}
    Supervisor.child_spec(default_worker_spec, id: id)
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
    :erlang.phash2(key, @default_num_workers)
  end
end
