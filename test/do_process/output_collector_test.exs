defmodule DoProcess.ResultCollectorTest do
  use ExUnit.Case, async: true

  alias DoProcess.ResultCollector

  test "it will append the stdout output" do
    {:ok, pid} = ResultCollector.start_link()

    result =
      pid
      |> ResultCollector.collect(:stdout, "hello ")
      |> ResultCollector.collect(:stdout, "world")
      |> ResultCollector.collect(:stdout, "!!!")
      |> ResultCollector.inspect

    assert "hello world!!!" == result.stdout
  end

  test "it will collect an exit_status" do
    {:ok, pid} = ResultCollector.start_link()

    result =
      pid
      |> ResultCollector.collect(:exit_status, 127)
      |> ResultCollector.inspect

    assert 127 == result.exit_status
  end

  test "it has a default exit_status of :unknown" do
    {:ok, pid} = ResultCollector.start_link()

    result = pid |> ResultCollector.inspect

    assert :unknown == result.exit_status
  end
end
