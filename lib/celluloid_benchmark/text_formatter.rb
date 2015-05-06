require "table_print"

module CelluloidBenchmark
  class TextFormatter
    def self.to_s(benchmark_run)
      tp benchmark_run.benchmarks, :label, :threshold, :average_response_time, :min_response_time, :max_response_time, :responses
    end
  end
end
