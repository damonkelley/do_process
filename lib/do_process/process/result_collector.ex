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

  def collect(config, :stdout, data) do
    GenServer.cast(via_tuple(config), {:stdout, data})
    config
  end

  def collect(config, :exit_status, data) do
    GenServer.cast(via_tuple(config), {:exit_status, data})
    config
  end

  def inspect(config) do
    GenServer.call(via_tuple(config), :inspect)
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
