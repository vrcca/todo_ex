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
    case start_child(name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  # HELPERS
  defp start_child(name) do
    DynamicSupervisor.start_child(__MODULE__, {Server, %{name: name}})
  end
end
