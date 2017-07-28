defmodule DoProcess.Process do

  alias __MODULE__.Options

  @type t :: %__MODULE__{}
  @enforce_keys [:name]
  defstruct [name: nil,
             command: nil,
             arguments: [],
             os_pid: nil,
             state: nil,
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

  def state(process, state) do
    %__MODULE__{process | state: state}
  end

  def options(%{options: options} = process, field, value) do
    %__MODULE__{process | options: Options.option(options, field, value)}
  end
end
