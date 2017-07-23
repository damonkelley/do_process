defmodule DoProcess.Process.ControllerTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process.Controller
  alias DoProcess.Process, as: Proc

  defmodule Worker do
    def kill(proc) do
      send self(), {:killed, proc.name}
      :ok
    end
  end

  setup do
    proc =
      TestProcess.new
      |> TestProcess.unique_registry_name
      |> Proc.options(:worker, Worker)

    {:ok, _} = DoProcess.Registry.start_link(proc.options.registry)
    Controller.start_link(proc)

    {:ok, [proc: proc]}
  end

  test "it will append the stdout output", %{proc: proc} do
    result =
      proc
      |> Controller.collect(:stdout, "hello ")
      |> Controller.collect(:stdout, "world")
      |> Controller.collect(:stdout, "!!!")
      |> Controller.result

    assert "hello world!!!" == result.stdout
  end

  test "it will collect an exit_status", %{proc: proc} do
    result =
      proc
      |> Controller.collect(:exit_status, 127)
      |> Controller.result

    assert 127 == result.exit_status
  end

  test "it will collect the os_pid", %{proc: proc} do
    proc =
      proc
      |> Controller.collect(:os_pid, 49012)
      |> Controller.process

    assert 49012 == proc.os_pid
  end

  test "it has a default exit_status of :unknown", %{proc: proc} do
    result = proc |> Controller.result

    assert :unknown == result.exit_status
  end

  test "it will kill a process", %{proc: proc} do
    :ok = Controller.kill(proc)
    %{name: name}  = proc
    assert_receive {:killed, ^name}
  end
end
