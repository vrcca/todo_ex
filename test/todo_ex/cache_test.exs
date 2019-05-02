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
    alice = Cache.server_process(cache, "alice")
    TodoEx.Server.add_entry(alice, %{date: ~D[2018-12-19], title: "Dentist"})
    entries = TodoEx.Server.entries(alice, ~D[2018-12-19])
    assert [%{date: ~D[2018-12-19], title: "Dentist"}] = entries
  end
end
