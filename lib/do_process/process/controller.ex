defmodule DoProcess.Process.Controller do
  @behaviour DoProcess.Process.Collector

  alias __MODULE__.Server

  def start_link(process) do
    Server.start_link(process)
  end

  def collect(process, :stdout, data) do
    GenServer.cast(Server.via_tuple(process), {:stdout, data})
    process
  end

  def collect(process, :exit_status, data) do
    GenServer.cast(Server.via_tuple(process), {:exit_status, data})
    process
  end

  def collect(process, :os_pid, data) do
    GenServer.cast(Server.via_tuple(process), {:os_pid, data})
    process
  end

  def result(process) do
    GenServer.call(Server.via_tuple(process), :result)
  end

  def process(process) do
    GenServer.call(Server.via_tuple(process), :process)
  end

  def kill(process) do
    process.options.worker.kill(process)
  end
end
