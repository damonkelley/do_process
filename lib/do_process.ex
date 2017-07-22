defmodule DoProcess do
  def start(config) do
    Supervisor.start_child(DoProcess.ProcessesSupervisor, [config])
    config
  end

  def result(config) do
    DoProcess.Process.ResultCollector.inspect(config)
  end
end
