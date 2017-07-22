defmodule DoProcess.Process.WorkerSupervisor do
  use Supervisor

  def start_link(process) do
    Supervisor.start_link(__MODULE__, process)
  end

  def init(%{restarts: restarts, options: options} = process) do
    children = [
      worker(options.worker, [process], restart: :transient),
    ]

    supervise(children, strategy: :one_for_one, max_restarts: restarts)
  end
end
