defmodule DoProcess.Process.Config do
  defstruct [process_args: nil,
             process_module: DoProcess.Process.Worker,
             restarts: 0,
             collector: nil]
end
