defmodule DoProcess.Result do
  defstruct [exit_status: nil]
end

defmodule DoProcess.Process do
  use GenServer
  alias DoProcess.Result

  def start_link(executable, args \\ [], callback \\ Port) do
    GenServer.start_link(__MODULE__, {executable, args, callback})
  end

  def init({executable, args, callback}) do
    {:ok,
      %{port: callback.open({:spawn_executable, executable}, [:binary, :exit_status, :stderr_to_stdout, args: args]),
        callback: callback,
        exit_status: nil,
        subscribers: [],
        output: "",
        result: %Result{exit_status: :in_progress}}}
  end

  def await(pid, timeout \\ :infinity) do
    subscribe(pid)
    receive do
      {_ref, {:result, result}} -> result
    after
      timeout -> result(pid)
    end
  end

  def result(pid) do
    GenServer.call(pid, :result)
  end

  def output(pid) do
    GenServer.call(pid, :output)
  end

  def input(pid, input) do
    GenServer.cast(pid, {:input, input})
  end

  def kill(pid) do
    GenServer.cast(pid, :kill)
    pid
  end

  def handle_call(:subscribe, from, %{subscribers: subscribers} = state) do
    {:reply, :ok, %{state | subscribers: [from | subscribers]}}
  end

  def handle_call(:result, _from, %{result: result} = state) do
    {:reply, result, state}
  end

  def handle_call(:output, _from, %{output: output} = state) do
    {:reply, output, state}
  end

  def handle_cast({:input, input}, %{port: port, callback: callback} = state) do
    callback.command(port, input)
    {:noreply, state}
  end

  def handle_cast(:finished, %{subscribers: subscribers} = state) do
    subscribers
    |> Enum.map(fn s -> GenServer.reply(s, :continue) end)
    {:noreply, state}
  end

  def handle_cast(:kill, %{result: result, callback: callback, port: port} = state) do
    callback.close(port)
    {:noreply, %{state | result: %Result{result | exit_status: :killed}}}
  end

  def handle_info({port, {:exit_status, exit_status}}, %{port: port, subscribers: subscribers, result: result} = state) do
    result = %Result{result| exit_status: exit_status}

    notify(subscribers, {:result, result})

    {:noreply, %{state | result: result}}
  end

  def handle_info({port, {:data, data}}, %{port: port, output: output} = state) do
    {:noreply, %{state | output: output <> data}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp subscribe(pid) do
    GenServer.call(pid, :subscribe)
  end

  defp notify(subscribers, msg) do
    subscribers
    |> Enum.map(fn s -> GenServer.reply(s, msg) end)
  end
end
