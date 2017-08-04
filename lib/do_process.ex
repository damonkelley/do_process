defmodule DoProcess do
  alias __MODULE__.Process
  alias __MODULE__.Process.Controller

  defdelegate start(process), to: Process
  defdelegate result(process), to: Controller
end
