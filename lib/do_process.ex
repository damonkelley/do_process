defmodule DoProcess do
  alias DoProcess.Process.Controller

  def start(process, opts \\ []) do
    supervisor = Keyword.get(opts, :supervisor, DoProcess.ProcessesSupervisor)
    {:ok, _} = Supervisor.start_child(supervisor, [process])
    process
  end

  defdelegate result(process), to: Controller
end
