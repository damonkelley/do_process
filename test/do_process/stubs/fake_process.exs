defmodule DoProcess.FakeProcess do
  use GenServer

  alias DoProcess.ResultCollector

  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  def init(%{collector: collector, exit_status: exit_status} = _config) do
    send(self(), {:port, {:data, "started "}})
    send(self(), {:port, {:exit_status, exit_status}})
    {:ok, collector}
  end

  def kill(_server) do
  end

  def handle_info({:port, {:data, data}}, collector) do
    ResultCollector.collect(collector, :stdout, data)
    {:noreply, collector}
  end

  def handle_info({:port, {:exit_status, 0}}, collector) do
    ResultCollector.collect(collector, :exit_status, 0)
    {:stop, :normal, collector}
  end

  def handle_info({:port, {:exit_status, exit_status}}, collector) do
    ResultCollector.collect(collector, :exit_status, exit_status)
    {:stop, :error, collector}
  end
end
