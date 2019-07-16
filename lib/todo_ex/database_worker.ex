defmodule TodoEx.DatabaseWorker do
  use GenServer

  def start_link(opts = %{id: id}) do
    GenServer.start_link(__MODULE__, opts, name: via_tuple(id))
  end

  @impl GenServer
  def init(opts) do
    IO.puts("Starting database worker.")
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

  def store(id, key, data) do
    GenServer.call(via_tuple(id), {:store, key, data})
  end

  def get(id, key) do
    GenServer.call(via_tuple(id), {:get, key})
  end

  defp file_name(key, %{db_folder: db_folder}), do: Path.join(db_folder, to_string(key))

  defp via_tuple(id) do
    TodoEx.ProcessRegistry.via_tuple({__MODULE__, id})
  end
end
