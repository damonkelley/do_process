ExUnit.start(exclude: [:skip])

for path <- Path.wildcard("#{Path.absname "."}/test/helpers/*.exs") do
  Code.require_file path
end

Registry.start_link(:unique, TestConfig.new().registry)
