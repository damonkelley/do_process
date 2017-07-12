defmodule DoProcess.Process do
  use GenServer

  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  def kill(pid) do
    GenServer.cast(pid, :kill)
  end

  def init(%{command: command, args: args, collector: collector} = _config) do
    port = Port.open({:spawn_executable, command}, [:binary, :exit_status, :stderr_to_stdout, args: args])
    ref = :erlang.monitor(:port, port)
    {:ok, %{port: port, ref: ref, collector: collector}}
  end

  def handle_cast(:kill, %{port: port} = state) do
    Port.close(port)
    {:noreply, state}
  end

  def handle_info({port, {:data, data}}, %{port: port, collector: collector} = state) do
    collect(collector, :stdout, data)
    {:noreply, state}
  end

  def handle_info({port, {:exit_status, 0}}, %{collector: collector, port: port} = state) do
    collect(collector, :exit_status, 0)
    {:stop, :normal, state}
  end

  def handle_info({port, {:exit_status, exit_status}}, %{collector: collector, port: port} = state) do
    collect(collector, :exit_status, exit_status)
    {:stop, :error, state}
  end

  def handle_info({:DOWN, ref, :port, port, :normal}, %{ref: ref, port: port} = state) do
    {:stop, :normal, state}
  end

  defp collect(collector, tag, data) do
    DoProcess.ResultCollector.collect(collector, tag, data)
  end
end
