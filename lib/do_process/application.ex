defmodule DoProcess.Application do
  use Application

  def start(_type, _start) do
    DoProcess.Supervisor.start_link()
  end
end
