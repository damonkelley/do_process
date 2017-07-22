defmodule DoProcess.Process.WorkerTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process.Worker
  alias DoProcess.Process, as: Proc
  alias DoProcess.Process.Server

  @moduletag :posix

  setup do
    Process.flag(:trap_exit, true)
    proc =
      TestProcess.posix()
      |> TestProcess.unique_registry_name

    {:ok, _} = DoProcess.Registry.start_link(proc.options.registry)
    {:ok, _} = Server.start_link(proc)

    {:ok, [proc: proc]}
  end

  test "it will run a command", %{proc: proc} do
    proc =
      proc
      |> Proc.command("/bin/echo")
      |> Proc.arguments(["hello world"])

    {:ok, pid} = Worker.start_link proc

    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, :process, ^pid, :normal}
  end

  @tag capture_log: true
  test "it will terminate with an error the port exits with a non-zero", %{proc: proc} do
    proc =
      proc
      |> Proc.command("/bin/bash")
      |> Proc.arguments(["-c", "not-a-command"])

    {:ok, pid} = Worker.start_link proc

    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, :process, ^pid, :error}
  end

  test "it will terminate normally if the port is killed", %{proc: proc} do
    proc = Proc.command(proc, "/bin/cat")

    {:ok, pid} = Worker.start_link proc

    ref = Process.monitor(pid)
    :ok = Worker.kill(proc)

    assert_receive {:DOWN, ^ref, :process, ^pid, :normal}
  end

  test "it will capture stdout", %{proc: proc} do
    proc =
      proc
      |> Proc.command("/bin/echo")
      |> Proc.arguments(["hello, world!"])

    Worker.start_link proc

    :timer.sleep(10)

    %{stdout: stdout} =
      proc
      |> Server.result
    assert "hello, world!\n" == stdout
  end

  @tag capture_log: true
  test "it will capture stderr", %{proc: proc} do
    proc =
      proc
      |> Proc.command("/bin/bash")
      |> Proc.arguments(["-c", "not-a-command"])

    Worker.start_link proc

    :timer.sleep(10)

    %{stdout: stdout} =
      proc
      |> Server.result
    assert stdout =~ "command not found"
  end

  test "it will forward the exit status to the server", %{proc: proc} do
    proc =
      proc
      |> Proc.command("/bin/echo")
      |> Proc.arguments(["hello, world!"])

    Worker.start_link proc

    :timer.sleep(10)

    %{exit_status: exit_status} =
      proc
      |> Server.result
    assert 0 == exit_status
  end

  test "it is registed with the procured registry", %{proc: proc} do
    proc =
      proc
      |> Proc.command("/bin/echo")
      |> Proc.arguments(["hello, world!"])

    {:ok, pid} = Worker.start_link proc

    assert [{pid, nil}] == Registry.lookup(proc.options.registry, {:worker, proc.name})
  end
end
