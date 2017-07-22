defmodule DoProcess.Process.FakeWorker do
  use GenServer

  alias DoProcess.Process.ResultCollector

  def start_link(config) do
    GenServer.start_link( __MODULE__, config, name: via_tuple(config))
  end

  def via_tuple(config) do
      {:via, Registry, {config.options.registry, {:worker, config.name}}}
  end

  def init(%{extras: extras} = config) do
    %{startup_fn: fun} = extras
    send(self(), {:port, {:data, "started "}})
    fun.()
    {:ok, config}
  end

  def kill(config) do
    GenServer.stop(via_tuple(config))
  end

  def handle_info({:port, {:data, data}}, config) do
    ResultCollector.collect(config, :stdout, data)
    {:noreply, config}
  end

  def handle_info({:port, {:exit_status, 0}}, config) do
    ResultCollector.collect(config, :exit_status, 0)
    {:stop, :normal, config}
  end

  def handle_info({:port, {:exit_status, exit_status}}, config) do
    ResultCollector.collect(config, :exit_status, exit_status)
    {:stop, :error, config}
  end
end
