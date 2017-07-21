defmodule DoProcess.Process.WorkerTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process.Worker
  alias DoProcess.Process.Config
  alias DoProcess.Process.ResultCollector

  @moduletag :posix

  setup do
    Process.flag(:trap_exit, true)
    config =
      TestConfig.posix()
      |> TestConfig.unique_registry_name

    {:ok, _} = DoProcess.Registry.start_link(config.registry)
    {:ok, _} = ResultCollector.start_link(config)

    {:ok, [config: config]}
  end

  test "it will run a command", %{config: config} do
    config = Config.process_args(config, %{command: "/bin/echo", args: ["hello world"]})

    {:ok, pid} = Worker.start_link config

    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, :process, ^pid, :normal}
  end

  @tag capture_log: true
  test "it will terminate with an error the port exits with a non-zero", %{config: config} do
    config = Config.process_args(config, %{command: "/bin/bash", args: ["-c", "not-a-command"]})

    {:ok, pid} = Worker.start_link config

    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, :process, ^pid, :error}
  end

  test "it will terminate normally if the port is killed", %{config: config} do
    config = Config.process_args(config, %{command: "/bin/cat", args: []})

    {:ok, pid} = Worker.start_link config

    ref = Process.monitor(pid)
    :ok = Worker.kill(config)

    assert_receive {:DOWN, ^ref, :process, ^pid, :normal}
  end

  test "it will capture stdout", %{config: config} do
    config = Config.process_args(config, %{command: "/bin/echo", args: ["hello, world!"]})

    Worker.start_link config

    :timer.sleep(10)

    %{stdout: stdout} =
      config
      |> ResultCollector.inspect
    assert "hello, world!\n" == stdout
  end

  @tag capture_log: true
  test "it will capture stderr", %{config: config} do
    config = Config.process_args(config, %{command: "/bin/bash", args: ["-c", "not-a-command"]})

    Worker.start_link config

    :timer.sleep(10)

    %{stdout: stdout} =
      config
      |> ResultCollector.inspect
    assert stdout =~ "command not found"
  end

  test "it will forward the exit status to the collector", %{config: config} do
    config = Config.process_args(config, %{command: "/bin/echo", args: ["hello, world!"]})

    Worker.start_link config

    :timer.sleep(10)

    %{exit_status: exit_status} =
      config
      |> ResultCollector.inspect
    assert 0 == exit_status
  end

  test "it is registed with the configured registry", %{config: config} do
    config = Config.process_args(config, %{command: "/bin/echo", args: ["hello, world!"]})

    {:ok, pid} = Worker.start_link config

    assert [{pid, nil}] == Registry.lookup(config.registry, {:worker, config.name})
  end
end
