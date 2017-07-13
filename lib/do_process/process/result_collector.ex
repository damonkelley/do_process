defmodule DoProcess.Process.ResultCollector do
  defmodule Result do
    defstruct [stdout: "", stderr: "", exit_status: :unknown]
  end

  def start_link(config) do
    GenServer.start_link(__MODULE__, %Result{}, name: via_tuple(config))
  end

  defp via_tuple(config) do
    {:via, Registry, {config.registry, {:collector, config.name}}}
  end

  def init(initial) do
    {:ok, initial}
  end

  def collect(pid, :stdout, data) do
    GenServer.cast(pid, {:stdout, data})
    pid
  end

  def collect(pid, :exit_status, data) do
    GenServer.cast(pid, {:exit_status, data})
    pid
  end

  def inspect(pid) do
    GenServer.call(pid, :inspect)
  end

  def handle_cast({:stdout, data}, %{stdout: stdout} = state) do
    {:noreply, %{state| stdout: stdout <> data}}
  end

  def handle_cast({:exit_status, exit_status}, state) do
    {:noreply, %{state| exit_status: exit_status}}
  end

  def handle_call(:inspect, _from, state) do
    {:reply, state, state}
  end
end
