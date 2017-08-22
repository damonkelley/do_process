ExUnit.start(exclude: [:skip])

for path <- Path.wildcard("#{Path.absname "."}/test/helpers/*.exs") do
  Code.require_file path
end
