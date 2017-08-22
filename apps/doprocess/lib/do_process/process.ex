defmodule DoProcess.Process do

  alias __MODULE__.Options

  @type t :: %__MODULE__{}
  @enforce_keys [:name]
  defstruct [name: nil,
             command: nil,
             arguments: [],
             state: nil,
             options: %Options{},
             extras: %{},
             restarts: 0]

  def new(name, command, opts \\ []) do
    arguments = Keyword.get(opts, :arguments, [])
    restarts  = Keyword.get(opts, :restarts, 0)
    extras = Keyword.get(opts, :extras, %{})

    %__MODULE__{
      name: name,
      command: command,
      arguments: arguments,
      restarts: restarts,
      extras: extras}
  end

  def start(process) do
    supervisor = process.options.supervisor
    supervisor.start_child(process)
    process
  end

  def kill(process) do
    process.options.controller.kill(process)
  end

  def state(process, state) do
    put(process, :state, state)
  end

  def options(%{options: options} = process, field, value) do
    put(process, :options, Options.option(options, field, value))
  end

  defp put(process, key, value) do
    Map.put(process, key, value)
  end
end
