defmodule DoProcess.Process.Worker do
  use GenServer

  alias DoProcess.Process.ResultCollector

  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  def kill(pid) do
    GenServer.cast(pid, :kill)
  end

  def init(%{process_args: %{command: command, args: args}} = config) do
    port = Port.open({:spawn_executable, command}, [:binary, :exit_status, :stderr_to_stdout, args: args])
    ref = :erlang.monitor(:port, port)
    {:ok, %{port: port, ref: ref, config: config}}
  end

  def handle_cast(:kill, %{port: port} = state) do
    Port.close(port)
    {:noreply, state}
  end

  def handle_info({port, {:data, data}}, %{port: port, config: config} = state) do
    collect(config.collector, :stdout, data)
    {:noreply, state}
  end

  def handle_info({port, {:exit_status, 0}}, %{config: config, port: port} = state) do
    collect(config.collector, :exit_status, 0)
    {:stop, :normal, state}
  end

  def handle_info({port, {:exit_status, exit_status}}, %{config: config, port: port} = state) do
    collect(config.collector, :exit_status, exit_status)
    {:stop, :error, state}
  end

  def handle_info({:DOWN, ref, :port, port, :normal}, %{ref: ref, port: port} = state) do
    {:stop, :normal, state}
  end

  defp collect(collector, tag, data) do
    ResultCollector.collect(collector, tag, data)
  end
end
