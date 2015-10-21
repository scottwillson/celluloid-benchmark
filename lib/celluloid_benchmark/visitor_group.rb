require "celluloid/current"
require_relative "benchmark_run"
require_relative "visitor"

module CelluloidBenchmark
  # Supervised Actor pool of Visitors
  class VisitorGroup < Celluloid::Supervision::Container
    supervise type: BenchmarkRun, as: :benchmark_run
    pool Visitor, as: :visitor_pool, size: Celluloid.cores * 8
  end
end
