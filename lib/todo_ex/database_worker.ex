defmodule TodoEx.DatabaseWorker do
  require Logger
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl GenServer
  def init(opts) do
    Logger.debug("Starting database worker. #{inspect(opts)}")
    {:ok, opts}
  end

  @impl GenServer
  def handle_call({:store, key, data}, _from, state) do
    key
    |> file_name(state)
    |> File.write!(:erlang.term_to_binary(data))

    {:reply, state, state}
  end

  @impl GenServer
  def handle_call({:get, key}, _from, state) do
    data =
      case File.read(file_name(key, state)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _others -> nil
      end

    {:reply, data, state}
  end

  # CLIENT API
  def store(pid, key, data) do
    GenServer.call(pid, {:store, key, data})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  # HELPERS
  defp file_name(key, %{db_folder: db_folder}), do: Path.join(db_folder, to_string(key))
end
