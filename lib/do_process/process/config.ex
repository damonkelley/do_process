defmodule DoProcess.Process.Config do
  @enforce_keys [:name]

  defstruct [name: nil,
             process_args: nil,
             process_module: DoProcess.Process.Worker,
             registry: DoProcess.Process.Registry,
             restarts: 0,
             collector: nil]

  def restarts(config, restarts) do
    %__MODULE__{config | restarts: restarts}
  end

  def process_args(config, process_args) do
    %__MODULE__{config | process_args: process_args}
  end

  def collector(config, collector) do
    %__MODULE__{config | collector: collector}
  end
end
