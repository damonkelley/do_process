defmodule DoProcess.Process.Controller.Server do
  alias DoProcess.Process, as: Proc

  defmodule State do
    defstruct [stdout: "", stderr: "", exit_status: :unknown, os_pid: nil]
  end

  def init(process) do
    {:ok, Proc.state(process, %State{})}
  end

  def handle_cast({:stdout, data}, %{state: state} = process) do
    %{stdout: stdout} = state
    {:noreply, Proc.state(process, %{state | stdout: stdout <> data})}
  end

  def handle_cast({:exit_status, exit_status}, %{state: state} = process) do
    {:noreply, Proc.state(process, %{state | exit_status: exit_status})}
  end

  def handle_cast({:os_pid, os_pid}, %{state: state} = process) do
    {:noreply, Proc.state(process, %{state | os_pid: os_pid})}
  end

  def handle_call(:state, _from, %{state: state} = process) do
    {:reply, state, process}
  end

  def handle_call(:process, _from, process) do
    {:reply, process, process}
  end
end
