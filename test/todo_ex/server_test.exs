defmodule TodoEx.ServerTest do
  use ExUnit.Case, async: true

  alias TodoEx.Server

  setup do
    server = start_supervised!(Server)
    %{server: server}
  end

  test "adds entries", %{server: server} do
    Server.add_entry(server, %{title: "New todo", date: ~D[2019-01-01]})
    entries = Server.entries(server, ~D[2019-01-01])
    assert [%{id: 1, title: "New todo", date: ~D[2019-01-01]}] = entries
  end

  test "updates entries", %{server: server} do
    entry = %{id: 1, title: "New todo", date: ~D[2019-01-01]}
    Server.add_entry(server, entry)
    Server.update_entry(server, %{entry | title: "My todo"})
    entries = Server.entries(server, ~D[2019-01-01])
    assert [%{id: 1, title: "My todo", date: ~D[2019-01-01]}] = entries
  end

  test "deletes entries", %{server: server} do
    entry = %{id: 1, title: "New todo", date: ~D[2019-01-01]}
    other_entry = %{id: 2, title: "To be deleted", date: ~D[2019-01-01]}
    Server.add_entry(server, entry)
    Server.add_entry(server, other_entry)
    Server.delete_entry(server, 2)
    entries = Server.entries(server, ~D[2019-01-01])
    assert [%{id: 1, title: "New todo"}] = entries
  end
end
