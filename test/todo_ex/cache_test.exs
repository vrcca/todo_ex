defmodule TodoEx.CacheTest do
  use ExUnit.Case
  alias TodoEx.Cache

  setup do
    cache = start_supervised!(Cache)
    %{cache: cache}
  end

  test "retrieves correct server by name", %{cache: cache} do
    bob_pid = Cache.server_process(cache, "bob")

    assert bob_pid != Cache.server_process(cache, "alice")
    assert bob_pid == Cache.server_process(cache, "bob")
  end

  test "to-do operations", %{cache: cache} do
    date = ~D[2018-12-19]
    alice = Cache.server_process(cache, "alice") |> delete_all_entries_at(date)

    TodoEx.Server.add_entry(alice, %{date: date, title: "Dentist"})

    entries = TodoEx.Server.entries(alice, date)
    assert [%{date: date, title: "Dentist"}] = entries
  end

  defp delete_all_entries_at(list, date) do
    TodoEx.Server.entries(list, date)
    |> Stream.map(fn entry -> entry.id end)
    |> Enum.each(fn id -> TodoEx.Server.delete_entry(list, id) end)

    list
  end
end
