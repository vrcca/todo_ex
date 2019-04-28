defmodule TodoEx.TodoServer do
  alias TodoEx.{TodoList, ServerProcess}
  require Logger

  @me __MODULE__

  def child_spec(opts) do
    %{
      id: @me,
      start: {@me, :start_link, [opts]}
    }
  end

  def init() do
    %TodoList{}
  end

  def start_link(_opts) do
    {:ok, start()}
  end

  def start() do
    ServerProcess.start(@me)
  end

  def handle_cast(request, todo_list) do
    process_message(todo_list, request)
  end

  def handle_call(request, todo_list) do
    {:ok, process_message(todo_list, request)}
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
    ServerProcess.call(server, {:add_entry, new_entry})
  end

  def update_entry(server, entry = %{}) do
    ServerProcess.call(server, {:update_entry, entry})
  end

  def delete_entry(server, id) do
    ServerProcess.cast(server, {:delete_entry, id})
  end

  def entries(server, date) do
    ServerProcess.call(server, {:entries, self(), date})
  end
end
