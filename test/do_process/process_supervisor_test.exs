defmodule DoProcess.ProcessSupervisorTest do
  use ExUnit.Case, async: true

  alias DoProcess.ProcessSupervisor
  alias DoProcess.ResultCollector
  alias DoProcess.FakeProcess

  setup do
    Process.flag(:trap_exit, true)
    {:ok, collector} = ResultCollector.start_link
    {:ok, [collector: collector]}
  end

  test "A process will be started", %{collector: collector} do
    config = %{command: "fake-command", args: [], exit_status: 0, collector: collector}

    ProcessSupervisor.start_link(config, 3, FakeProcess)

    %{stdout: stdout} = ResultCollector.inspect(collector)
    assert "started " == stdout
  end

  @tag capture_log: true
  test "A process will be restarted if is exits abnormally", %{collector: collector} do
    config = %{command: "fake-command", args: [], exit_status: 1, collector: collector}

    {:ok, pid} = ProcessSupervisor.start_link(config, 3, FakeProcess)

    assert_receive {:EXIT, ^pid, :shutdown}

    %{stdout: stdout} = ResultCollector.inspect(collector)
    assert "started started started started " == stdout
  end
end
