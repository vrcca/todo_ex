defmodule TodoEx.TodoServer do
  alias TodoEx.{TodoList}
  require Logger
  use GenServer

  def start_link(opts) do
    GenServer.start(__MODULE__, opts)
  end

  def init(_opts) do
    {:ok, %TodoList{}}
  end

  def handle_cast(request, todo_list) do
    {:noreply, process_message(todo_list, request)}
  end

  def handle_call(request, _from, todo_list) do
    new_state = process_message(todo_list, request)
    {:reply, new_state, new_state}
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:update_entry, entry}) do
    TodoList.update_entry(todo_list, entry)
  end

  defp process_message(todo_list, {:delete_entry, id}) do
    TodoList.delete_entry(todo_list, id)
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
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
    GenServer.call(server, {:entries, self(), date})
  end
end
