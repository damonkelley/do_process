defmodule DoProcess.Process.Options do
  defstruct [worker: DoProcess.Process.Worker,
             server: DoProcess.Process.Controller,
             processes_supervisor: DoProcess.ProcessesSupervisor,
             registry: DoProcess.Registry]

  def option(options, :worker, worker) do
    %__MODULE__{options | worker: worker}
  end

  def option(options, :registry, registry) do
    %__MODULE__{options | registry: registry}
  end

  def option(options, :server, server) do
    %__MODULE__{options | server: server}
  end

  def option(options, :processes_supervisor, server) do
    %__MODULE__{options | processes_supervisor: server}
  end
end

