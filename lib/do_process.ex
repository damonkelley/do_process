defmodule DoProcess do
  alias DoProcess.Process.Controller

  defdelegate start(process), to: DoProcess.Server
  defdelegate result(process), to: Controller
end
