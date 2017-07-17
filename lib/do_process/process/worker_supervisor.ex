defmodule DoProcess.Process.WorkerSupervisor do
  use Supervisor

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config)
  end

  def init(%{restarts: restarts, worker_module: module} = config) do
    children = [
      worker(module, [config], restart: :transient),
    ]

    supervise(children, strategy: :one_for_one, max_restarts: restarts)
  end
end
