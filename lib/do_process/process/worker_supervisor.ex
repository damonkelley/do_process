defmodule DoProcess.Process.WorkerSupervisor do
  use Supervisor

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config)
  end

  def init(%{restarts: restarts, options: options} = config) do
    children = [
      worker(options.worker, [config], restart: :transient),
    ]

    supervise(children, strategy: :one_for_one, max_restarts: restarts)
  end
end
