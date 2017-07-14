defmodule DoProcess.Process.WorkerSupervisorTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process.WorkerSupervisor
  alias DoProcess.Process.ResultCollector
  alias DoProcess.Process.Config

  setup do
    Process.flag(:trap_exit, true)

    config =
      TestConfig.new
      |> Config.restarts(3)
      |> TestConfig.start_collector(ResultCollector, :start_link)

    {:ok, [config: config]}
  end

  test "it will start a process will be started", %{config: config} do
    WorkerSupervisor.start_link(config)

    assert "started " == stdout(config)
  end

  @tag capture_log: true
  test "it will restart a process if is exits abnormally", %{config: config} do
    config = TestConfig.exit_status(config, 1)

    {:ok, pid} = WorkerSupervisor.start_link(config)

    assert_receive {:EXIT, ^pid, :shutdown}
    assert "started started started started " == stdout(config)
  end

  defp stdout(config) do
    %{stdout: stdout} =
      config
      |> ResultCollector.inspect
    stdout
  end
end
