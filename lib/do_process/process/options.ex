defmodule DoProcess.Process.Options do
  defstruct [worker: DoProcess.Process.Worker,
             controller: DoProcess.Process.Controller,
             supervisor: DoProcess.ProcessesSupervisor,
             registry: DoProcess.Registry]

  def option(options, :worker, worker) do
    %__MODULE__{options | worker: worker}
  end

  def option(options, :registry, registry) do
    %__MODULE__{options | registry: registry}
  end

  def option(options, :controller, controller) do
    %__MODULE__{options | controller: controller}
  end

  def option(options, :supervisor, supervisor) do
    %__MODULE__{options | supervisor: supervisor}
  end
end

