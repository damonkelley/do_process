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

  def command(config, command) do
    %__MODULE__{config | command: command}
  end

  def arguments(config, arguments) do
    %__MODULE__{config | arguments: arguments}
  end

  def restarts(config, restarts) do
    %__MODULE__{config | restarts: restarts}
  end
end
