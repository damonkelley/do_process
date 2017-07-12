ExUnit.start(exclude: [:skip])

for path <- Path.wildcard("#{Path.absname "."}/test/stubs/*.exs") do
  Code.require_file path
end
