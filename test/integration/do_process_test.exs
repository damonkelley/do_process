defmodule DoProcessIntegrationTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process, as: Proc

  @moduletag capture_log: true
  @moduletag :integration

  setup do
    Application.ensure_started(:do_process)
    on_exit fn ->
      Application.stop(:do_process)
    end
  end

  test "it will create a process that exits successfully" do
    result =
      TestProcess.new
      |> TestProcess.exit_status(0)
      |> DoProcess.start
      |> DoProcess.result

    assert %{exit_status: 0} = result
  end

  test "it will create a daemon process" do
    result =
      TestProcess.new
      |> DoProcess.start
      |> DoProcess.result

    assert %{exit_status: :unknown} = result
  end

  test "it will create two isolated processes" do
    daemon = TestProcess.new
             |> Proc.restarts(3)
             |> DoProcess.start
             |> DoProcess.result

    failure = TestProcess.new
              |> TestProcess.exit_status(1)
              |> Proc.restarts(4)
              |> DoProcess.start
              |> DoProcess.result

    assert 1 == failure.exit_status
    assert :unknown == daemon.exit_status
  end
end
