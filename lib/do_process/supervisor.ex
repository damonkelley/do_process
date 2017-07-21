defmodule DoProcess.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(DoProcess.Registry, [], restart: :permanent),
      worker(DoProcess.ProcessesSupervisor, [], restart: :permanent)
    ]

    supervise(children, strategy: :one_for_one)
  end
end
