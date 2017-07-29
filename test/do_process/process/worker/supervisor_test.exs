defmodule DoProcess.Process.Worker.SupervisorTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process.Worker.Supervisor, as: WorkerSupervisor
  alias DoProcess.Process, as: Proc

  defmodule Worker do
    use GenServer

    def start_link(%{extras: extras, name: name} = _process) do
      send extras.test_pid, "started"
      GenServer.start_link(__MODULE__, [], name: name)
    end

    def init(_) do
      {:ok, nil}
    end
  end

  defmodule FailingWorker do
    use GenServer

    def start_link(%{extras: extras, name: name}) do
      send extras.test_pid, "started"
      GenServer.start_link(__MODULE__, [], name: name)
    end

    def init(_) do
      Process.send_after(self(), :error, 10)
      {:ok, nil}
    end

    def handle_info(:error, _state) do
      Process.exit(self(), :error)
    end
  end

  setup do
    Process.flag(:trap_exit, true)
    :ok
  end

  test "it will start a proc will be started", context do
    proc =
      context.test
      |> Proc.new("command", extras: %{test_pid: self()})
      |> Proc.options(:worker, Worker)

    {:ok, _} = WorkerSupervisor.start_link(proc)

    assert_receive "started"
  end

  @tag capture_log: true
  test "it will restart a proc if is exits abnormally", context do
    proc =
      context.test
      |> Proc.new("command", restarts: 3, extras: %{test_pid: self()})
      |> Proc.options(:worker, FailingWorker)

    {:ok, pid} = WorkerSupervisor.start_link(proc)

    for _ <- 0..proc.restarts do
      assert_receive "started"
    end

    assert_receive {:EXIT, ^pid, :shutdown}
  end
end
