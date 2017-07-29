defmodule DoProcess.ProcessTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process, as: Proc

  defmodule TestSupervisor do
    def start_child(_process) do
      send self(), :start_from_supervisor
    end
  end

  defmodule TestController do
    def kill(process) do
      send self(), :killed_from_controller
      process
    end
  end
  test "it will create a new proc" do
    proc = Proc.new "name", "command"

    assert "name" == proc.name
    assert "command" == proc.command
    assert [] == proc.arguments
    assert 0 == proc.restarts
  end

  test "it will create a new proc with options" do
    proc = Proc.new("name", "command",
                    arguments: ["arg"], restarts: 4)

    assert ["arg"] == proc.arguments
    assert 4 == proc.restarts
  end

  test "it will accepts custom options" do
    proc =
      Proc.new("name", "command")
      |> Proc.options(:worker, MyWorker)
      |> Proc.options(:registry, MyRegistry)
      |> Proc.options(:server, MyServer)

    assert MyWorker == proc.options.worker
    assert MyRegistry == proc.options.registry
    assert MyServer == proc.options.server
  end

  test "it will start a process" do
    Proc.new("name", "command")
    |> Proc.options(:processes_supervisor, TestSupervisor)
    |> Proc.start

    assert_receive :start_from_supervisor
  end

  test "it will kill a process" do
      Proc.new("name", "command")
      |> Proc.options(:processes_supervisor, TestSupervisor)
      |> Proc.options(:server, TestController)
      |> Proc.start
      |> Proc.kill

    assert_receive :killed_from_controller
  end
end
