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

  setup context do
    proc =
      Proc.new(context.test, "command")
      |> Proc.options(:worker, Worker)
      |> Proc.options(:registry, context.test)

    {:ok, _} = DoProcess.Registry.start_link(proc.options.registry)
    {:ok, _} = Controller.start_link(proc)

    {:ok, [proc: proc]}
  end

  test "it will append the stdout output", %{proc: proc} do
    state =
      proc
      |> Controller.collect(:stdout, "hello ")
      |> Controller.collect(:stdout, "world")
      |> Controller.collect(:stdout, "!!!")
      |> Controller.state

    assert "hello world!!!" == state.stdout
  end

  test "it will collect an exit_status", %{proc: proc} do
    state =
      proc
      |> Controller.collect(:exit_status, 127)
      |> Controller.state

    assert 127 == state.exit_status
  end

  test "it will collect the os_pid", %{proc: proc} do
    proc =
      proc
      |> Controller.collect(:os_pid, 49012)
      |> Controller.state

    assert 49012 == proc.os_pid
  end

  test "it has a default exit_status of :unknown", %{proc: proc} do
    state = proc |> Controller.state

    assert :unknown == state.exit_status
  end

  test "it will kill a process", %{proc: proc} do
    :ok = Controller.kill(proc)
    %{name: name}  = proc
    assert_receive {:killed, ^name}
  end
end
