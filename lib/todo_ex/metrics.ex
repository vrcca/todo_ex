defmodule TodoEx.Metrics do
  use Task
  require Logger

  def start_link(_arg) do
    Task.start_link(&loop/0)
  end

  def loop() do
    Process.sleep(:timer.seconds(10))
    Logger.debug("Current system metrics: #{inspect(collect_metricts())}")
    loop()
  end

  defp collect_metricts() do
    [
      memory_usage: :erlang.memory(:total),
      process_count: :erlang.system_info(:process_count)
    ]
  end
end
