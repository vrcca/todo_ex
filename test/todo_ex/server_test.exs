defmodule TodoEx.ServerTest do
  use ExUnit.Case, async: true

  alias TodoEx.Server
  alias TodoEx.Database

  setup do
    start_supervised!({Database, %{num_workers: 1, db_folder: "./priv/db_temp"}})
    server = start_supervised!({Server, "simple todo"})
    Server.clear_entries(server)
    %{server: server}
  end

  test "adds entries", %{server: server} do
    date = ~D[2019-01-02]
    Server.add_entry(server, %{title: "New todo", date: date})
    entries = Server.entries(server, date)
    assert [%{title: "New todo", date: ^date}] = entries
  end

  test "updates entries", %{server: server} do
    date = ~D[2019-01-05]
    Server.add_entry(server, %{title: "New todo", date: date})
    [entry] = Server.entries(server, date)

    Server.update_entry(server, %{entry | title: "My todo"})

    entries = Server.entries(server, date)
    assert [%{id: id, title: "My todo", date: ^date}] = entries
  end

  test "deletes entries", %{server: server} do
    date = ~D[2019-01-03]
    Server.add_entry(server, %{title: "To be deleted", date: date})
    [entry] = Server.entries(server, date)
    Server.add_entry(server, %{title: "Other entry", date: date})

    Server.delete_entry(server, entry.id)

    entries = Server.entries(server, date)
    assert [%{title: "Other entry"}] = entries
  end
end
