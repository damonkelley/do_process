defmodule DoProcess.Process.Worker.Server do

  def init(%{command: command, arguments: args} = process) do
    port = Port.open({:spawn_executable, command},
                     [:binary, :exit_status, :stderr_to_stdout, args: args])

    ref = :erlang.monitor(:port, port)
    {:ok, %{port: port, ref: ref, process: process}}
  end

  def handle_cast(:kill, %{port: port} = state) do
    Port.close(port)
    {:noreply, state}
  end

  def handle_info({port, {:data, data}}, %{port: port, process: process} = state) do
    collect(process, :stdout, data)
    {:noreply, state}
  end

  def handle_info({port, {:exit_status, 0}}, %{process: process, port: port} = state) do
    collect(process, :exit_status, 0)
    {:stop, :normal, state}
  end

  def handle_info({port, {:exit_status, exit_status}}, %{process: process, port: port} = state) do
    collect(process, :exit_status, exit_status)
    {:stop, :error, state}
  end

  def handle_info({:DOWN, ref, :port, port, :normal}, %{ref: ref, port: port} = state) do
    {:stop, :normal, state}
  end

  defp collect(process, tag, data) do
    process.options.server.collect(process, tag, data)
  end
end
