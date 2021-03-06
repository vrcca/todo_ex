defmodule TodoEx.ListTest do
  use ExUnit.Case, async: true

  alias TodoEx.List

  test "adds entries with new id" do
    todo_list =
      List.new()
      |> List.add_entry(%{title: "New todo", date: ~D[2019-01-01]})

    assert todo_list.auto_id == 2
    assert map_size(todo_list.entries) == 1
  end

  test "filters entries by date" do
    older_entry = %{title: "Older todo", date: ~D[2019-01-01]}
    newer_entry = %{title: "Newer todo", date: ~D[2019-01-03]}

    todo_list =
      List.new()
      |> List.add_entry(older_entry)
      |> List.add_entry(newer_entry)

    entries = todo_list |> List.entries(~D[2019-01-03])

    assert length(entries) == 1
    assert hd(entries).title == newer_entry.title
    assert hd(entries).date == newer_entry.date
  end

  test "updates entries" do
    older_entry = %{title: "Older todo", date: ~D[2019-01-01]}
    newer_entry = %{title: "Newer todo", date: ~D[2019-01-03]}

    todo_list =
      List.new()
      |> List.add_entry(older_entry)
      |> List.add_entry(newer_entry)

    entries =
      todo_list
      |> List.update_entry(1, &Map.put(&1, :date, ~D[2019-01-03]))
      |> List.entries(~D[2019-01-03])

    assert length(entries) == 2
  end

  test "updates entries with alternative interface" do
    older_entry = %{title: "Older todo", date: ~D[2019-01-01]}
    newer_entry = %{title: "Newer todo", date: ~D[2019-01-03]}

    todo_list =
      List.new()
      |> List.add_entry(older_entry)
      |> List.add_entry(newer_entry)

    entries =
      todo_list
      |> List.update_entry(%{id: 1, title: "New too", date: ~D[2019-01-03]})
      |> List.entries(~D[2019-01-03])

    assert length(entries) == 2
  end

  test "does not updates entry when id does not exist" do
    older_entry = %{title: "Older todo", date: ~D[2019-01-01]}
    newer_entry = %{title: "Newer todo", date: ~D[2019-01-03]}

    todo_list =
      List.new()
      |> List.add_entry(older_entry)
      |> List.add_entry(newer_entry)

    entries =
      todo_list
      |> List.update_entry(999, &Map.put(&1, :date, ~D[2019-01-03]))
      |> List.entries(~D[2019-01-03])

    assert length(entries) == 1
  end

  test "does not allow updating entry's id" do
    older_entry = %{title: "Older todo", date: ~D[2019-01-01]}
    newer_entry = %{title: "Newer todo", date: ~D[2019-01-03]}

    todo_list =
      List.new()
      |> List.add_entry(older_entry)
      |> List.add_entry(newer_entry)

    assert_raise MatchError, fn ->
      todo_list
      |> List.update_entry(1, &Map.put(&1, :id, 12310))
    end
  end

  test "creates todo list with initial list of entries" do
    initial_entries = [
      %{title: "Todo 1", date: ~D[2019-01-01]},
      %{title: "Todo 2", date: ~D[2019-01-01]},
      %{title: "Todo 3", date: ~D[2019-01-01]}
    ]

    todo_list = List.new(initial_entries)

    entries =
      todo_list
      |> List.entries(~D[2019-01-01])

    assert todo_list.auto_id == 4
    assert length(entries) == 3
  end

  test "deletes entries" do
    initial_entries = [
      %{title: "Todo 1", date: ~D[2019-01-01]},
      %{title: "Todo 2", date: ~D[2019-01-01]}
    ]

    todo_list = List.new(initial_entries)

    entries =
      todo_list
      |> List.delete_entry(2)
      |> List.entries(~D[2019-01-01])

    assert length(entries) == 1
  end

  test "nothing happens when deleting unknown entry" do
    todo_list =
      List.new()
      |> List.delete_entry(333)

    assert todo_list.entries == %{}
  end
end
