defmodule TodoEx.Cache do
  use GenServer
  alias TodoEx.{Database, Server}

  def start_link(opts \\ []) do
    GenServer.start(__MODULE__, opts)
  end

  def init(_opts) do
    Database.start_link()
    {:ok, %{}}
  end

  def handle_call({:server_process, name}, _from, servers) do
    case Map.fetch(servers, name) do
      {:ok, server} ->
        {:reply, server, servers}

      :error ->
        {:ok, new_server} = Server.start_link(name)
        {:reply, new_server, Map.put(servers, name, new_server)}
    end
  end

  # Client API
  def server_process(cache, name) do
    GenServer.call(cache, {:server_process, name})
  end
end
