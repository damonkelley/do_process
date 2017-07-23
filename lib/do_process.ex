defmodule DoProcess do
  alias DoProcess.Process.Server, as: ProcessServer

  defdelegate start(process), to: DoProcess.Server
  defdelegate result(process), to: ProcessServer
end
