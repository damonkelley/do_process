defmodule DoProcess.Process.WorkerSupervisorTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process.WorkerSupervisor
  alias DoProcess.Process.ResultCollector
  alias DoProcess.Process.FakeWorker
  alias DoProcess.Process.Config

  setup do
    Process.flag(:trap_exit, true)
    {:ok, collector} = ResultCollector.start_link

    config = %Config{
      process_args: %{command: "fake-command", args: [], exit_status: 0},
      process_module: FakeWorker,
      restarts: 3,
      collector: collector}

    {:ok, [config: config]}
  end

  test "A process will be started", %{config: config} do
    WorkerSupervisor.start_link(config)

    %{stdout: stdout} = ResultCollector.inspect(config.collector)
    assert "started " == stdout
  end

  @tag capture_log: true
  test "A process will be restarted if is exits abnormally", %{config: config} do
    config = %Config{config | process_args: %{command: "command", args: [], exit_status: 1}}

    {:ok, pid} = WorkerSupervisor.start_link(config)

    assert_receive {:EXIT, ^pid, :shutdown}

    %{stdout: stdout} = ResultCollector.inspect(config.collector)
    assert "started started started started " == stdout
  end
end
