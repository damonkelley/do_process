defmodule DoProcess.Process.Controller.Server do
  alias DoProcess.Process, as: Proc

  defmodule Result do
    defstruct [stdout: "", stderr: "", exit_status: :unknown]
  end

  def start_link(process) do
    GenServer.start_link(__MODULE__, process, name: via_tuple(process))
  end

  def via_tuple(process) do
    {:via, Registry, {process.options.registry, {:server, process.name}}}
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
