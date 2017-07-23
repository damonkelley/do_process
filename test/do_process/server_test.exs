defmodule DoProcess.ServerTest do
  use ExUnit.Case, async: true

  alias DoProcess.Server

  defmodule TestWorker do
    def start_link(process)do
      Agent.start_link fn -> process end
    end
  end

  defmodule TestSupervisor do
    use Supervisor
    def start_link(name) do
      Supervisor.start_link(__MODULE__, [], name: name)
    end

    def init(_) do
      children = [worker(TestWorker, [], restart: :permanent)]
      supervise(children, strategy: :simple_one_for_one)
    end
  end

  test "it will start a process", context do
    TestSupervisor.start_link(context.test)
    proc = TestProcess.new

    Server.start_link(context.test)
    Server.start(proc)

    assert %{active: 1} = Supervisor.count_children(context.test)
  end
end
