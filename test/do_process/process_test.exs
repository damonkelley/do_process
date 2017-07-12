defmodule DoProcess.ProcessTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process

  @moduletag :posix

  setup do
    Elixir.Process.flag(:trap_exit, true)
    {:ok, collector} = DoProcess.ResultCollector.start_link()
    {:ok, [collector: collector]}
  end

  test "it will run a command", %{collector: collector} do
    {:ok, pid} =
      %{command: "/bin/echo", args: ["hello world"], collector: collector}
      |> Process.start_link

    ref = Elixir.Process.monitor(pid)
    assert_receive {:DOWN, ^ref, :process, ^pid, :normal}
  end

  @tag capture_log: true
  test "it will terminate with an error the port exits with a non-zero", %{collector: collector} do
    {:ok, pid} =
      %{command: "/bin/bash", args: ["-c", "not-a-command"], collector: collector}
      |> Process.start_link

    ref = Elixir.Process.monitor(pid)
    assert_receive {:DOWN, ^ref, :process, ^pid, :error}
  end

  test "it will terminate normally if the port is killed", %{collector: collector} do
    {:ok, pid} =
      %{command: "/bin/cat", args: [], collector: collector}
      |> Process.start_link

    ref = Elixir.Process.monitor(pid)
    :ok = Process.kill(pid)

    assert_receive {:DOWN, ^ref, :process, ^pid, :normal}
  end

  test "it will capture stdout", %{collector: collector} do
      %{command: "/bin/echo", args: ["hello, world!"], collector: collector}
      |> Process.start_link

    :timer.sleep(100)

    %{stdout: stdout} = DoProcess.ResultCollector.inspect(collector)
    assert "hello, world!\n" == stdout
  end

  @tag capture_log: true
  test "it will capture stderr", %{collector: collector} do
    {:ok, _pid} =
      %{command: "/bin/bash", args: ["-c", "not-a-command"], collector: collector}
      |> Process.start_link

    :timer.sleep(100)

    %{stdout: stdout} = DoProcess.ResultCollector.inspect(collector)
    assert stdout =~ "command not found"
  end

  test "it will forward the exit status to the collector", %{collector: collector} do
      %{command: "/bin/echo", args: ["hello world"], collector: collector}
      |> Process.start_link

    :timer.sleep(100)

    %{exit_status: exit_status} = DoProcess.ResultCollector.inspect(collector)
    assert 0 == exit_status
  end
end
