defmodule DoProcess.Process.Worker do
  use GenServer

  alias __MODULE__.Server

  def start_link(process) do
    GenServer.start_link(Server, process, name: via_tuple(process))
  end

  defp via_tuple(process) do
    {:via, Registry, {process.options.registry, {:worker, process.name}}}
  end

  def kill(process) do
    GenServer.cast(via_tuple(process), :kill)
  end
end
