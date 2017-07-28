defmodule DoProcess.Collector do
  alias DoProcess.Process, as: Proc

  @type collectable :: :stdout | :exit_status | :os_pid
  @callback collect(Proc.t, collectable, term) :: Proc.t
end
