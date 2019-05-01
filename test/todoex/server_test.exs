defmodule TodoEx.ServerTest do
  use ExUnit.Case, async: true

  alias TodoEx.Server

  setup do
    server = start_supervised!(Server)
    %{server: server}
  end

  test "adds entries", %{server: server} do
    Server.add_entry(server, %{title: "New todo", date: ~D[2019-01-01]})
    Server.entries(server, ~D[2019-01-01])

    assert_receive {:todo_entries, entries}
    assert length(entries) == 1
    assert hd(entries).id == 1
    assert hd(entries).title == "New todo"
    assert hd(entries).date == ~D[2019-01-01]
  end

  test "updates entries", %{server: server} do
    entry = %{id: 1, title: "New todo", date: ~D[2019-01-01]}
    Server.add_entry(server, entry)
    Server.update_entry(server, %{entry | title: "My todo"})
    Server.entries(server, ~D[2019-01-01])

    assert_receive {:todo_entries, entries}
    assert hd(entries).id == 1
    assert hd(entries).title == "My todo"
    assert hd(entries).date == ~D[2019-01-01]
  end

  test "deletes entries", %{server: server} do
    entry = %{id: 1, title: "New todo", date: ~D[2019-01-01]}
    other_entry = %{id: 2, title: "To be deleted", date: ~D[2019-01-01]}
    Server.add_entry(server, entry)
    Server.add_entry(server, other_entry)
    Server.delete_entry(server, 2)
    Server.entries(server, ~D[2019-01-01])

    assert_receive {:todo_entries, entries}
    assert hd(entries).id == 1
    assert hd(entries).title == "New todo"
  end
end
