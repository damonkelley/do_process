defmodule TestProcess do
  alias DoProcess.Process, as: Proc
  alias DoProcess.Process.Options
  alias DoProcess.Process.FakeWorker

  def new, do: name() |> new
  def new(name) do
    %Proc{
      name: name,
      command: "/bin/echo",
      arguments: ["hello, world"],
      extras: extras(),
      options: %Options{worker: FakeWorker}}
  end

  defp extras do
      %{startup_fn: fn -> nil end}
  end

  def posix, do: name() |> new
  def posix(name) do
    config = new(name)
    %Proc{config |
      options: %Options{config.options | worker: Worker}}
  end

  def name do
    length = 20
    :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
  end

  def exit_status(%{extras: args} = config, exit_status) do
    startup_fn = fn -> send self(), {:port, {:exit_status, exit_status}} end
    %Proc{config | extras: Map.put(args, :startup_fn, startup_fn)
    }
  end

  def unique_registry_name(%{name: name} = config) when is_atom(name) do
    options = %Options{config.options | registry: name}
    %Proc{config | options: options}
  end

  def unique_registry_name(%{name: name} = config) do
    options = %Options{config.options | registry: String.to_atom(name)}
    %Proc{config | options: options}
  end
end
