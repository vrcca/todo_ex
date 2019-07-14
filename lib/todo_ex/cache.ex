defmodule TodoEx.Cache do
  use GenServer
  alias TodoEx.Server

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    IO.puts("Starting to-do cache.")
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
  def server_process(name) do
    GenServer.call(__MODULE__, {:server_process, name})
  end
end
