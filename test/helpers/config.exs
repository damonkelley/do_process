defmodule TestConfig do
  alias DoProcess.Process.Config

  @default_process_args %{command: "/bin/echo", args: ["hello, world"], exit_status: 0}

  def new(process_args \\ @default_process_args) do
    %Config{
      name: name(),
      process_args: process_args,
      process_module: DoProcess.Process.FakeWorker}
  end

  def posix(process_args \\ @default_process_args) do
    %Config{new(process_args) | process_module: DoProcess.Process.Worker}
  end

  def name do
    length = 20
    :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
  end

  def exit_status(%{process_args: args} = config, exit_status) do
    %Config{config | process_args: Map.put(args, :exit_status, exit_status)}
  end

  def start_collector(config, m, f) do
    {:ok, pid} = apply(m, f, [config])
    Config.collector(config, pid)
  end
end
