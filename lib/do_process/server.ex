defmodule DoProcess.Server do
  use GenServer

  def start_link(supervisor) do
    GenServer.start_link(__MODULE__, supervisor, name: __MODULE__)
  end

  def start(proc) do
    GenServer.call(__MODULE__, {:start, proc})
  end

  def list do
    GenServer.call(__MODULE__, :list)
  end

  def init(supervisor) do
    {:ok, %{supervisor: supervisor, procs: []}}
  end

  def handle_call({:start, proc}, _from, state) do
    %{supervisor: supervisor, procs: procs} = state
    Supervisor.start_child(supervisor, [proc])
    {:reply, proc, %{state | procs: [proc | procs]}}
  end

  def handle_call(:list, _from, %{procs: procs} = state) do
    {:reply, procs, state}
  end
end
