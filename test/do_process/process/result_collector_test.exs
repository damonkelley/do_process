defmodule DoProcess.Process.ResultCollectorTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process.ResultCollector

  setup do
    proc =
      TestProcess.new
      |> TestProcess.unique_registry_name

    {:ok, _} = DoProcess.Registry.start_link(proc.options.registry)

    {:ok, [proc: proc]}
  end

  test "it will append the stdout output", %{proc: proc} do
    ResultCollector.start_link(proc)

    result =
      proc
      |> ResultCollector.collect(:stdout, "hello ")
      |> ResultCollector.collect(:stdout, "world")
      |> ResultCollector.collect(:stdout, "!!!")
      |> ResultCollector.inspect

    assert "hello world!!!" == result.stdout
  end

  test "it will collect an exit_status", %{proc: proc} do
    ResultCollector.start_link(proc)

    result =
      proc
      |> ResultCollector.collect(:exit_status, 127)
      |> ResultCollector.inspect

    assert 127 == result.exit_status
  end

  test "it has a default exit_status of :unknown", %{proc: proc} do
    ResultCollector.start_link(proc)

    result = proc |> ResultCollector.inspect

    assert :unknown == result.exit_status
  end

  test "it is registered in the registry", %{proc: proc} do
    {:ok, pid} = ResultCollector.start_link(proc)
    assert [{pid, nil}] == Registry.lookup(proc.options.registry, {:collector, proc.name})
  end
end
