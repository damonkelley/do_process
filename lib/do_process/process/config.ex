defmodule DoProcess.Process.Config do
  @enforce_keys [:name]

  defstruct [name: nil,
             process_args: nil,
             worker_module: DoProcess.Process.Worker,
             registry: DoProcess.Registry,
             restarts: 0]

  def new(name, process_args) do
    %__MODULE__{name: name, process_args: process_args}
  end

  def restarts(config, restarts) do
    %__MODULE__{config | restarts: restarts}
  end

  def process_args(config, process_args) do
    %__MODULE__{config | process_args: process_args}
  end
end
