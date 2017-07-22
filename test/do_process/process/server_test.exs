defmodule DoProcess.Process.ServerTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process.Server

  setup do
    proc =
      TestProcess.new
      |> TestProcess.unique_registry_name

    {:ok, _} = DoProcess.Registry.start_link(proc.options.registry)

    {:ok, [proc: proc]}
  end

  test "it will append the stdout output", %{proc: proc} do
    Server.start_link(proc)

    result =
      proc
      |> Server.collect(:stdout, "hello ")
      |> Server.collect(:stdout, "world")
      |> Server.collect(:stdout, "!!!")
      |> Server.result

    assert "hello world!!!" == result.stdout
  end

  test "it will collect an exit_status", %{proc: proc} do
    Server.start_link(proc)

    result =
      proc
      |> Server.collect(:exit_status, 127)
      |> Server.result

    assert 127 == result.exit_status
  end

  test "it will collect the os_pid", %{proc: proc} do
    Server.start_link(proc)

    proc =
      proc
      |> Server.collect(:os_pid, 49012)
      |> Server.process

    assert 49012 == proc.os_pid
  end

  test "it has a default exit_status of :unknown", %{proc: proc} do
    Server.start_link(proc)

    result = proc |> Server.result

    assert :unknown == result.exit_status
  end

  test "it is registered in the registry", %{proc: proc} do
    {:ok, pid} = Server.start_link(proc)
    assert [{pid, nil}] == Registry.lookup(proc.options.registry, {:server, proc.name})
  end
end
