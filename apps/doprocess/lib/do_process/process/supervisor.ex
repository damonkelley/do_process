defmodule DoProcess.Process.Supervisor do
  use Supervisor

  def start_link(process) do
    Supervisor.start_link(__MODULE__, process)
  end

  def init(process) do
    children = [
      worker(DoProcess.Process.Controller, [process], restart: :transient),
      supervisor(DoProcess.Process.Worker.Supervisor, [process], restart: :transient)
    ]

    supervise(children, strategy: :one_for_one)
  end
end
