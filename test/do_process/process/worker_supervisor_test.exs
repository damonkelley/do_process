defmodule DoProcess.Process.WorkerSupervisorTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process.WorkerSupervisor
  alias DoProcess.Process.ResultCollector
  alias DoProcess.Process, as: Proc

  setup do
    Process.flag(:trap_exit, true)
    proc =
      TestProcess.new
      |> Proc.restarts(3)
      |> TestProcess.unique_registry_name

    {:ok, _} = DoProcess.Registry.start_link(proc.options.registry)
    {:ok, _} = ResultCollector.start_link(proc)

    {:ok, [proc: proc]}
  end

  test "it will start a proc will be started", %{proc: proc} do
    WorkerSupervisor.start_link(proc)

    assert "started " == stdout(proc)
  end

  @tag capture_log: true
  test "it will restart a proc if is exits abnormally", %{proc: proc} do
    proc = TestProcess.exit_status(proc, 1)

    {:ok, pid} = WorkerSupervisor.start_link(proc)

    assert_receive {:EXIT, ^pid, :shutdown}
    assert "started started started started " == stdout(proc)
  end

  defp stdout(proc) do
    %{stdout: stdout} = ResultCollector.inspect(proc)
    stdout
  end
end
