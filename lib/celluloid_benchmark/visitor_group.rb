require "celluloid"
require_relative "benchmark_run"
require_relative "visitor"

module CelluloidBenchmark
  # Supervised Actor pool of Visitors
  class VisitorGroup < Celluloid::SupervisionGroup
    supervise BenchmarkRun, as: :benchmark_run
    pool Visitor, as: :visitor_pool, size: 4
  end
end
