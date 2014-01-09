#! /usr/bin/env ruby

require_relative "lib/celluloid_benchmark"

benchmark_run = CelluloidBenchmark::Runner.run ARGV[0], (ARGV[1] || 20).to_i

p benchmark_run
puts
p "#{benchmark_run.requests / benchmark_run.elapsed_time} requests per second. #{benchmark_run.requests} requests in #{benchmark_run.elapsed_time} seconds by #{Celluloid::Actor[:visitor_pool].size} visitors."

puts
benchmark_run.benchmarks.each do |trans|
  puts "#{trans.ok? ? '[ OK ]' : '[FAIL]'} #{trans.label}"
end

exit benchmark_run.ok?
