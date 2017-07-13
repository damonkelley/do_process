defmodule DoProcess.Process.WorkerTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process.Worker
  alias DoProcess.Process.Config
  alias DoProcess.Process.ResultCollector

  @moduletag :posix

  setup do
    Process.flag(:trap_exit, true)
    {:ok, collector} = ResultCollector.start_link()
    config = %Config{collector: collector}

    {:ok, [collector: collector, config: config]}
  end

  test "it will run a command", %{config: config} do
    process_args = %{command: "/bin/echo", args: ["hello world"]}

    config = %Config{config | process_args: process_args}
    {:ok, pid} = Worker.start_link config

    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, :process, ^pid, :normal}
  end

  @tag capture_log: true
  test "it will terminate with an error the port exits with a non-zero", %{config: config} do
    process_args = %{command: "/bin/bash", args: ["-c", "not-a-command"]}

    config = %Config{config | process_args: process_args}
    {:ok, pid} = Worker.start_link config

    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, :process, ^pid, :error}
  end

  test "it will terminate normally if the port is killed", %{config: config} do
    process_args = %{command: "/bin/cat", args: []}

    config = %Config{config | process_args: process_args}
    {:ok, pid} = Worker.start_link config

    ref = Process.monitor(pid)
    :ok = Worker.kill(pid)

    assert_receive {:DOWN, ^ref, :process, ^pid, :normal}
  end

  test "it will capture stdout", %{config: config} do
    process_args = %{command: "/bin/echo", args: ["hello, world!"]}

    config = %Config{config | process_args: process_args}
    Worker.start_link config

    :timer.sleep(5)

    %{stdout: stdout} = ResultCollector.inspect(config.collector)
    assert "hello, world!\n" == stdout
  end

  @tag capture_log: true
  test "it will capture stderr", %{config: config} do
    process_args = %{command: "/bin/bash", args: ["-c", "not-a-command"]}

    config = %Config{config | process_args: process_args}
    Worker.start_link config

    :timer.sleep(5)

    %{stdout: stdout} = ResultCollector.inspect(config.collector)
    assert stdout =~ "command not found"
  end

  test "it will forward the exit status to the collector", %{config: config} do
    process_args = %{command: "/bin/echo", args: ["hello world"]}
    config = %Config{config | process_args: process_args}
    Worker.start_link config

    :timer.sleep(5)

    %{exit_status: exit_status} = ResultCollector.inspect(config.collector)
    assert 0 == exit_status
  end
end
