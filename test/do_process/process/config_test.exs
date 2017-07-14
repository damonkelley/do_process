defmodule DoProcess.Process.ConfigTest do
  use ExUnit.Case, async: true

  alias DoProcess.Process.Config

  test "it will create a new config" do
    config = Config.new "name", "process_args"

    assert "name" == config.name
    assert "process_args" == config.process_args
  end
end
