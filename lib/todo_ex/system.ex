defmodule TodoEx.System do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    children = [
      TodoEx.Metrics,
      TodoEx.ProcessRegistry,
      {TodoEx.Database, %{}},
      TodoEx.Cache
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
