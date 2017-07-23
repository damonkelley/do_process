defmodule DoProcess.Process.FakeWorker do
  use GenServer

  alias DoProcess.Process.Controller

  def start_link(process) do
    GenServer.start_link( __MODULE__, process, name: via_tuple(process))
  end

  def via_tuple(process) do
      {:via, Registry, {process.options.registry, {:worker, process.name}}}
  end

  def init(%{extras: extras} = process) do
    %{startup_fn: fun} = extras
    send(self(), {:port, {:data, "started "}})
    fun.()
    {:ok, process}
  end

  def kill(process) do
    GenServer.stop(via_tuple(process))
  end

  def handle_info({:port, {:data, data}}, process) do
    Controller.collect(process, :stdout, data)
    {:noreply, process}
  end

  def handle_info({:port, {:exit_status, 0}}, process) do
    Controller.collect(process, :exit_status, 0)
    {:stop, :normal, process}
  end

  def handle_info({:port, {:exit_status, exit_status}}, process) do
    Controller.collect(process, :exit_status, exit_status)
    {:stop, :error, process}
  end
end
