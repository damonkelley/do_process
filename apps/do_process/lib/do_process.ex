defmodule DoProcess do
  alias __MODULE__.Process
  alias __MODULE__.Process.Controller

  defdelegate start(process), to: Process
  defdelegate kill(process), to: Process
  defdelegate state(process), to: Controller
end
