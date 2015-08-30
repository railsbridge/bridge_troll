#!/usr/bin/env ruby

puts "Paste a list of rspec failures, followed by a blank line:"

lines = []
while line = gets
  break if line == "\n"
  lines << line
end

tests = lines.map { |line| line.match(/rspec (.*?) #/)[1] }.compact
cmd = "rspec #{tests.join(' ')}"
puts cmd
exec(cmd)
