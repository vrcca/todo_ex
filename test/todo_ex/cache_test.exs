defmodule TodoEx.CacheTest do
  use ExUnit.Case
  alias TodoEx.Cache

  setup do
    start_supervised!(Cache)
    :ok
  end

  test "retrieves correct server by name" do
    bob_pid = Cache.server_process("bob")

    assert bob_pid != Cache.server_process("kenya")
    assert bob_pid == Cache.server_process("bob")
  end
end
