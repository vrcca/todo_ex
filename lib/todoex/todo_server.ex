defmodule TodoEx.TodoServer do
  alias TodoEx.TodoList

  @me __MODULE__

  def child_spec(opts) do
    %{
      id: @me,
      start: {@me, :start_link, [opts]}
    }
  end

  def start_link(_opts) do
    {:ok, start()}
  end

  def start() do
    spawn(fn -> loop(TodoList.new()) end)
  end

  defp loop(todo_list) do
    new_todo_list =
      receive do
        message -> process_message(todo_list, message)
      end

    loop(new_todo_list)
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

  # Client methods
  def add_entry(server, new_entry = %{}) do
    send(server, {:add_entry, new_entry})
  end

  def update_entry(server, entry = %{}) do
    send(server, {:update_entry, entry})
  end

  def delete_entry(server, id) do
    send(server, {:delete_entry, id})
  end

  def entries(server, date) do
    send(server, {:entries, self(), date})
  end
end
