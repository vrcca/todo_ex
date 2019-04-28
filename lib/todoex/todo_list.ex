defmodule TodoEx.TodoList do
  alias TodoEx.TodoList

  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(entries, %TodoList{},
      fn entry, todo_list ->
        todo_list |> add_entry(entry)
      end)
  end

  def add_entry(todo_list = %TodoList{auto_id: auto_id, entries: entries}, entry = %{}) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = Map.put(entries, auto_id, entry)

    %TodoList{todo_list |
              entries: new_entries,
              auto_id: auto_id + 1
    }
  end

  def entries(%TodoList{entries: entries}, date) do
    entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_entry(todo_list = %TodoList{entries: entries}, entry_id, updater_fun) do
    case Map.fetch(entries, entry_id) do
      :error ->
        todo_list
      {:ok, old_entry = %{id: old_entry_id}} ->
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = Map.put(entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def update_entry(todo_list = %TodoList{}, entry = %{id: id}) do
    update_entry(todo_list, id, fn _ -> entry end)
  end
end
