defmodule TodoEx.Cache do
  require Logger
  alias TodoEx.Server

  def start_link(_opts) do
    Logger.info("Starting to-do cache.")
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  # Client API
  def server_process(name) do
    :rpc.call(node_for_list(name), TodoEx.Cache, :server_process_locally, [name])
  end

  def server_process_locally(name) do
    case DynamicSupervisor.start_child(__MODULE__, {Server, %{name: name}}) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  # HELPERS
  defp node_for_list(name) do
    all_sorted_nodes = Enum.sort(Node.list([:this, :visible]))

    node_index = :erlang.phash2(name, length(all_sorted_nodes))

    Enum.at(all_sorted_nodes, node_index)
  end
end
