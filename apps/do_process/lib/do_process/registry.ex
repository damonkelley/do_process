defmodule DoProcess.Registry do
  def start_link(name \\ __MODULE__) do
    Registry.start_link(:unique, name)
  end
end
