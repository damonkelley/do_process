defmodule DoProcess.Process.FakeWorker do
  use GenServer

  alias DoProcess.Process.ResultCollector

  def start_link(config) do
    GenServer.start_link(
      __MODULE__,
      config,
      name: {:via, Registry, {config.registry, {:worker, config.name}}})
  end

  def init(%{process_args: process_args} = config) do
    %{startup_fn: fun} = process_args
    send(self(), {:port, {:data, "started "}})
    fun.(process_args)
    {:ok, config}
  end

  def kill(_server) do
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
