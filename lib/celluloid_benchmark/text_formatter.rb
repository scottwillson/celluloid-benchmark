require "table_print"

module CelluloidBenchmark
  class TextFormatter
    def self.to_s(benchmark_run)
      tp benchmark_run.benchmarks.sort_by(&:label), :label, :threshold, :average_response_time, :min_response_time, :max_response_time, :responses
    end

    def self.status_text(trans)
      if trans.ok?
        "[ OK ]"
      elsif trans.error?
        "[ERR ]"
      else
        "[FAIL]"
      end
    end
  end
end
