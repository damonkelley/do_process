defmodule DoProcess.ProcessesSupervisor do
  use Supervisor

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    Supervisor.start_link(__MODULE__, [], name: name)
  end

  def init(_) do
    children = [
      supervisor(DoProcess.Process.Supervisor, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def start_child(process, opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    Supervisor.start_child(name, [process])
  end
end
