defmodule DoProcess.Process.ResultCollectorTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process.ResultCollector

  setup do
    config = TestConfig.new
             |> TestConfig.unique_registry_name

    {:ok, _} = DoProcess.Registry.start_link(config.registry)

    {:ok, [config: config]}
  end

  test "it will append the stdout output", %{config: config} do
    ResultCollector.start_link(config)

    result =
      config
      |> ResultCollector.collect(:stdout, "hello ")
      |> ResultCollector.collect(:stdout, "world")
      |> ResultCollector.collect(:stdout, "!!!")
      |> ResultCollector.inspect

    assert "hello world!!!" == result.stdout
  end

  test "it will collect an exit_status", %{config: config} do
    ResultCollector.start_link(config)

    result =
      config
      |> ResultCollector.collect(:exit_status, 127)
      |> ResultCollector.inspect

    assert 127 == result.exit_status
  end

  test "it has a default exit_status of :unknown", %{config: config} do
    ResultCollector.start_link(config)

    result = config |> ResultCollector.inspect

    assert :unknown == result.exit_status
  end

  test "it is registered in the registry", %{config: config} do
    {:ok, pid} = ResultCollector.start_link(config)
    assert [{pid, nil}] == Registry.lookup(config.registry, {:collector, config.name})
  end
end
