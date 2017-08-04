defmodule DoProcessIntegrationTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process, as: Proc
  alias DoProcess.Process.FakeWorker

  @moduletag capture_log: true
  @moduletag :integration

  setup do
    {:ok, _} = DoProcess.Application.start(nil, nil)
    :ok
  end

  test "it will create a process that exits successfully", context do
    state =
      context.test
      |> Proc.new("command", extras: %{startup_fn: exit_status(0)})
      |> Proc.options(:worker, FakeWorker)
      |> DoProcess.start
      |> DoProcess.state

    assert %{exit_status: 0} = state
  end

  test "it will create a daemon process", context do
    state =
      context.test
      |> Proc.new("command")
      |> Proc.options(:worker, FakeWorker)
      |> DoProcess.start
      |> DoProcess.state

    assert %{exit_status: :unknown} = state
  end

  test "it will create two isolated processes" do
    daemon =
      "daemon"
      |> Proc.new("command")
      |> Proc.options(:worker, FakeWorker)
      |> DoProcess.start
      |> DoProcess.state

    failure =
      "failure"
      |> Proc.new("command", restarts: 4,  extras: %{startup_fn: exit_status(1)})
      |> Proc.options(:worker, FakeWorker)
      |> DoProcess.start
      |> DoProcess.state

    assert 1 == failure.exit_status
    assert :unknown == daemon.exit_status
  end

  defp exit_status(status) do
    fn -> send self(), {:port, {:exit_status, status}} end
  end
end
