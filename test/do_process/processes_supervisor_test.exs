defmodule DoProcess.ProcessesSupervisorTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process
  alias DoProcess.ProcessesSupervisor

  defmodule Worker do
    use GenServer
    def start_link(%{extras: extras} = process) do
      send(extras.pid, {:child_started_with, process})
      GenServer.start_link(__MODULE__, nil)
    end

    def init(_) do
      {:ok, nil}
    end
  end

  setup context do
    {:ok, _} = DoProcess.Registry.start_link
    {:ok, _} = ProcessesSupervisor.start_link(name: context.test)
    :ok
  end

  test "it will start a child", context do
    process =
      context.test
      |> Process.new("command", extras: %{pid: self()})
      |> Process.options(:worker, Worker)

    ProcessesSupervisor.start_child(process, name: context.test)

    assert_receive {:child_started_with, ^process}
  end
end
