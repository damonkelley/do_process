defmodule DoProcess.ProcessSupervisor do
  use Supervisor

  def start_link(config, restarts, module \\ DoProcess.Process) do
    Supervisor.start_link(__MODULE__, [config, restarts, module])
  end

  def init([config, restarts, module]) do
    children = [
      worker(module, [config], restart: :transient),
    ]

    supervise(children, strategy: :one_for_one, max_restarts: restarts)
  end
end
