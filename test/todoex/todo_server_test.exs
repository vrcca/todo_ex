defmodule TodoEx.TodoServerTest do
  use ExUnit.Case, async: true

  alias TodoEx.TodoServer

  setup do
    server = start_supervised!(TodoServer)
    %{server: server}
  end

  test "adds entries", %{server: server} do
    TodoServer.add_entry(server, %{title: "New todo", date: ~D[2019-01-01]})
    TodoServer.entries(server, ~D[2019-01-01])

    assert_receive {:todo_entries, entries}
    assert length(entries) == 1
    assert hd(entries).id == 1
    assert hd(entries).title == "New todo"
    assert hd(entries).date == ~D[2019-01-01]
  end

  test "updates entries", %{server: server} do
    entry = %{id: 1, title: "New todo", date: ~D[2019-01-01]}
    TodoServer.add_entry(server, entry)
    TodoServer.update_entry(server, %{entry | title: "My todo"})
    TodoServer.entries(server, ~D[2019-01-01])

    assert_receive {:todo_entries, entries}
    assert hd(entries).id == 1
    assert hd(entries).title == "My todo"
    assert hd(entries).date == ~D[2019-01-01]
  end

  test "deletes entries", %{server: server} do
    entry = %{id: 1, title: "New todo", date: ~D[2019-01-01]}
    other_entry = %{id: 2, title: "To be deleted", date: ~D[2019-01-01]}
    TodoServer.add_entry(server, entry)
    TodoServer.add_entry(server, other_entry)
    TodoServer.delete_entry(server, 2)
    TodoServer.entries(server, ~D[2019-01-01])

    assert_receive {:todo_entries, entries}
    assert hd(entries).id == 1
    assert hd(entries).title == "New todo"
  end
end
