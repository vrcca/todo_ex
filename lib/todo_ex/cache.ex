defmodule TodoEx.Cache do
  use GenServer

  def start_link() do
    GenServer.start(__MODULE__, nil)
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_call({:server_process, name}, _from, servers) do
    case Map.fetch(servers, name) do
      {:ok, server} ->
        {:reply, server, servers}

      :error ->
        {:ok, new_server} = TodoEx.Server.start_link()
        {:reply, new_server, Map.put(servers, name, new_server)}
    end
  end

  # Client API
  def server_process(cache, name) do
    GenServer.call(cache, {:server_process, name})
  end
end
