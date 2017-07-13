defmodule DoProcess.Process.WorkerTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process.Worker
  alias DoProcess.Process.Config
  alias DoProcess.Process.ResultCollector

  @moduletag :posix

  setup do
    Process.flag(:trap_exit, true)
    # config = %Config{name: "test process"}
    config =
      TestConfig.posix()
      |> TestConfig.start_collector(ResultCollector, :start_link)

    {:ok, [config: config]}
  end

  test "it will run a command", %{config: config} do
    config =
      config
      |> Config.process_args(%{command: "/bin/echo", args: ["hello world"]})

    {:ok, pid} = Worker.start_link config

    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, :process, ^pid, :normal}
  end

  @tag capture_log: true
  test "it will terminate with an error the port exits with a non-zero", %{config: config} do
    config =
      config
      |> Config.process_args(%{command: "/bin/bash", args: ["-c", "not-a-command"]})

    {:ok, pid} = Worker.start_link config

    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, :process, ^pid, :error}
  end

  test "it will terminate normally if the port is killed", %{config: config} do
    config =
      config
      |> Config.process_args(%{command: "/bin/cat", args: []})

    {:ok, pid} = Worker.start_link config

    ref = Process.monitor(pid)
    :ok = Worker.kill(pid)

    assert_receive {:DOWN, ^ref, :process, ^pid, :normal}
  end

  test "it will capture stdout", %{config: config} do
    config =
      config
      |> Config.process_args(%{command: "/bin/echo", args: ["hello, world!"]})

    Worker.start_link config

    :timer.sleep(10)

    %{stdout: stdout} = ResultCollector.inspect(config.collector)
    assert "hello, world!\n" == stdout
  end

  @tag capture_log: true
  test "it will capture stderr", %{config: config} do
    config =
      config
      |> Config.process_args(%{command: "/bin/bash", args: ["-c", "not-a-command"]})

    Worker.start_link config

    :timer.sleep(10)

    %{stdout: stdout} = ResultCollector.inspect(config.collector)
    assert stdout =~ "command not found"
  end

  test "it will forward the exit status to the collector", %{config: config} do
    config =
      config
      |> Config.process_args(%{command: "/bin/echo", args: ["hello, world!"]})

    Worker.start_link config

    :timer.sleep(10)

    %{exit_status: exit_status} = ResultCollector.inspect(config.collector)
    assert 0 == exit_status
  end

  test "it is registed with the configured registry", %{config: config} do
    config =
      config
      |> Config.process_args(%{command: "/bin/echo", args: ["hello, world!"]})

    {:ok, pid} = Worker.start_link config

    assert [{pid, nil}] == Registry.lookup(config.registry, {:worker, config.name})
  end
end
