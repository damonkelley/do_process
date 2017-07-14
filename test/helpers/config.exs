defmodule TestConfig do
  alias DoProcess.Process.Config

  def new, do: default_process_args() |> new()
  def new(process_args) do
    %Config{
      name: name(),
      process_args: process_args,
      process_module: DoProcess.Process.FakeWorker}
  end

  def posix, do: default_process_args() |> posix()
  def posix(process_args) do
    %Config{new(process_args) | process_module: DoProcess.Process.Worker}
  end

  def name do
    length = 20
    :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
  end

  def exit_status(%{process_args: args} = config, exit_status) do
    startup_fn = fn _ -> send self(), {:port, {:exit_status, exit_status}} end
    %Config{config | process_args: Map.put(args, :startup_fn, startup_fn)}
  end

  def start_collector(config, m, f) do
    apply(m, f, [config])
    config
  end

  defp default_process_args do
    %{command: "/bin/echo",
      args: ["hello, world"],
      startup_fn: fn _ -> nil end}
  end
end
