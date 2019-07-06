defmodule TodoEx.DatabaseWorker do
  use GenServer

  def start(opts) do
    GenServer.start(__MODULE__, opts)
  end

  def init(db_folder: db_folder) do
    {:ok, %{db_folder: db_folder}}
  end

  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def handle_cast({:store, key, data}, state) do
    key
    |> file_name(state)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  def handle_call({:get, key}, _from, state) do
    data =
      case File.read(file_name(key, state)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _others -> nil
      end

    {:reply, data, state}
  end

  defp file_name(key, %{db_folder: db_folder}), do: Path.join(db_folder, to_string(key))
end
