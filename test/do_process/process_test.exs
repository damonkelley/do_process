defmodule DoProcess.ProcessTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process

  @moduletag :posix

  test "it will start a command" do
    {:ok, pid} = Process.start_link "/bin/echo", ["hello world!"]
    result = Process.await(pid, 100)

    assert 0 == result.exit_status
  end

  test "it can have a error exit status" do
    {:ok, pid} = Process.start_link "/bin/bash", ["-c", "not a command"]
    result = Process.await(pid, 100)

    assert 127 == result.exit_status
  end

  test "it will capture stderr" do
    {:ok, pid} = Process.start_link "/bin/bash", ["-c", "not a command"]

    Process.await(pid, 100)
    output = Process.output(pid)

    assert output =~ "command not found\n"
  end

  test "it will have a result of in progress if the process isn't finished" do
    {:ok, pid} = Process.start_link "/bin/cat"

    result = Process.result(pid)

    assert :in_progress == result.exit_status
  end

  test "it will collect output" do
    {:ok, pid} = Process.start_link "/bin/echo", ["hello, world!"]

    Process.await(pid, 100)

    assert "hello, world!\n" == Process.output(pid)
  end

  test "it will accept input" do
    {:ok, pid} = Process.start_link "/bin/cat"

    Process.input(pid, "foo bar")
    :timer.sleep 100

    assert "foo bar" == Process.output(pid)
  end

  test "it can be killed" do
    {:ok, pid} = Process.start_link "/bin/cat"

    result =
      pid
      |> Process.kill
      |> Process.await(50)

    assert :killed == result.exit_status
  end
end
