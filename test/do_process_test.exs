defmodule DoProcessTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process.FakeWorker
  alias DoProcess.Process, as: Proc

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

    proc =
      context.test
      |> Proc.new("command")
      |> Proc.options(:worker, FakeWorker)

    DoProcess.start(proc, supervisor: context.test)

    assert %{active: 1} = Supervisor.count_children(context.test)
  end
end
