defmodule DoProcess.Process.Worker do
  use GenServer

  alias __MODULE__.Server

  def start_link(process) do
    Server.start_link(process)
  end

  def kill(process) do
    GenServer.cast(Server.via_tuple(process), :kill)
  end
end
