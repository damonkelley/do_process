defmodule DoProcess.Process.Controller do
  @behaviour DoProcess.Collector

  alias __MODULE__.Server

  def start_link(process) do
    GenServer.start_link(Server, process, name: via_tuple(process))
  end

  defp via_tuple(process) do
    {:via, Registry, {process.options.registry, {:server, process.name}}}
  end

  def collect(process, :stdout, data) do
    GenServer.cast(via_tuple(process), {:stdout, data})
    process
  end

  def collect(process, :exit_status, data) do
    GenServer.cast(via_tuple(process), {:exit_status, data})
    process
  end

  def collect(process, :os_pid, data) do
    GenServer.cast(via_tuple(process), {:os_pid, data})
    process
  end

  def result(process) do
    GenServer.call(via_tuple(process), :state)
  end

  def kill(process) do
    process.options.worker.kill(process)
  end
end
