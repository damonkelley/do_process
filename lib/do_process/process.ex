defmodule DoProcess.Process.Options do
  defstruct [worker: DoProcess.Process.Worker,
             registry: DoProcess.Registry]
end

defmodule DoProcess.Process do

  alias DoProcess.Process.Options

  @enforce_keys [:name]
  defstruct [name: nil,
             command: nil,
             arguments: [],
             os_pid: nil,
             result: nil,
             options: %Options{},
             extras: %{},
             restarts: 0]

  def new(name, command, opts \\ []) do
    arguments = Keyword.get(opts, :arguments, [])
    restarts  = Keyword.get(opts, :restarts, 0)

    %__MODULE__{name: name,
                command: command,
                arguments: arguments,
                restarts: restarts}
  end

  def command(process, command) do
    %__MODULE__{process | command: command}
  end

  def arguments(process, arguments) do
    %__MODULE__{process | arguments: arguments}
  end

  def restarts(process, restarts) do
    %__MODULE__{process | restarts: restarts}
  end

  def result(process, result) do
    %__MODULE__{process | result: result}
  end
end
