defmodule DoProcess do
  def start(process) do
    Supervisor.start_child(DoProcess.ProcessesSupervisor, [process])
    process
  end

  def result(process) do
    DoProcess.Process.Server.result(process)
  end
end
