defmodule TodoEx.Server do
  require Logger
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start(__MODULE__, opts)
  end

  @impl GenServer
  def init(_opts) do
    {:ok, %TodoEx.List{}}
  end

  @impl GenServer
  def handle_cast(request, todo_list) do
    {:noreply, process_message(todo_list, request)}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, todo_list) do
    entries = TodoEx.List.entries(todo_list, date)
    {:reply, entries, todo_list}
  end

  @impl GenServer
  def handle_call(request, _from, todo_list) do
    new_state = process_message(todo_list, request)
    {:reply, new_state, new_state}
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoEx.List.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:update_entry, entry}) do
    TodoEx.List.update_entry(todo_list, entry)
  end

  defp process_message(todo_list, {:delete_entry, id}) do
    TodoEx.List.delete_entry(todo_list, id)
  end

  defp process_message(todo_list, unknown_message) do
    Logger.warn("There is no handler for message: #{unknown_message}!")
    todo_list
  end

  # Client methods
  def add_entry(server, new_entry = %{}) do
    GenServer.call(server, {:add_entry, new_entry})
  end

  def update_entry(server, entry = %{}) do
    GenServer.call(server, {:update_entry, entry})
  end

  def delete_entry(server, id) do
    GenServer.cast(server, {:delete_entry, id})
  end

  def entries(server, date) do
    GenServer.call(server, {:entries, date})
  end
end
