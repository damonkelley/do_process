defmodule DoProcess do
  use Application

  def start(_type, _start) do
    DoProcess.Supervisor.start_link()
  end

  def start(config) do
    Supervisor.start_child(DoProcess.ProcessesSupervisor, [config])
    config
  end

  def result(config) do
    DoProcess.Process.ResultCollector.inspect(config)
  end
end
