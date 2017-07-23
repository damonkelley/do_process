defmodule DoProcess.Process.Server do
  alias DoProcess.Process, as: Proc

  defmodule Result do
    defstruct [stdout: "", stderr: "", exit_status: :unknown]
  end

  def start_link(process) do
    GenServer.start_link(__MODULE__, process, name: via_tuple(process))
  end

  defp via_tuple(process) do
    {:via, Registry, {process.options.registry, {:server, process.name}}}
  end

  def collect(process, :stdout, data) do
    GenServer.cast(via_tuple(process), {:stdout, data})
    process
  end

  def collect(process, :exit_status, data) do
    GenServer.cast(via_tuple(process), {:exit_status, data})
    process
  end

  def collect(process, :os_pid, data) do
    GenServer.cast(via_tuple(process), {:os_pid, data})
    process
  end

  def result(process) do
    GenServer.call(via_tuple(process), :result)
  end

  def process(process) do
    GenServer.call(via_tuple(process), :process)
  end

  def kill(process) do
    process.options.worker.kill(process)
  end

  def init(process) do
    {:ok, Proc.result(process, %Result{})}
  end

  def handle_cast({:stdout, data}, %{result: result} = process) do
    %{stdout: stdout} = result
    {:noreply, Proc.result(process, %{result | stdout: stdout <> data})}
  end

  def handle_cast({:exit_status, exit_status}, %{result: result} = process) do
    {:noreply, Proc.result(process, %{result | exit_status: exit_status})}
  end

  def handle_cast({:os_pid, os_pid}, process) do
    {:noreply, %Proc{process| os_pid: os_pid}}
  end

  def handle_call(:result, _from, %{result: result} = process) do
    {:reply, result, process}
  end

  def handle_call(:process, _from, process) do
    {:reply, process, process}
  end
end
