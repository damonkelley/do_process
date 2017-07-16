defmodule DoProcessTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process.Config

  test "it will create a process that exits successfully" do
    result =
      TestConfig.new
      |> TestConfig.exit_status(0)
      |> DoProcess.start
      |> DoProcess.result

    assert %{exit_status: 0} = result
  end

  test "it will create a daemon process" do
    result =
      TestConfig.new
      |> DoProcess.start
      |> DoProcess.result

    assert %{exit_status: :unknown} = result
  end

  @tag capture_log: true
  test "it will create two isolated processes" do
    daemon = TestConfig.new
             |> Config.restarts(3)
             |> DoProcess.start
             |> DoProcess.result

    failure = TestConfig.new
              |> TestConfig.exit_status(1)
              |> Config.restarts(4)
              |> DoProcess.start
              |> DoProcess.result

    assert 1 == failure.exit_status
    assert :unknown == daemon.exit_status
  end
end
