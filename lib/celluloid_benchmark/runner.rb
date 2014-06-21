require "celluloid"
require_relative "session"
require_relative "visitor_group"

Celluloid.logger = nil

module CelluloidBenchmark
  # Run a scenario in several Visitors and return a BenchmarkRun
  class Runner
    def self.run(session_path, duration = 20, visitors = nil)
      raise("session_path is required") unless session_path
      raise("'#{session_path}' does not exist") unless File.exists?(session_path)

      require session_path

      VisitorGroup.run!

      visitors = visitors_count(visitors)
      benchmark_run = Celluloid::Actor[:benchmark_run]
      benchmark_run.visitors = visitors

      benchmark_run.mark_start
      futures = run_sessions(benchmark_run, duration, visitors)
      futures.map(&:value)
      benchmark_run.mark_end

      benchmark_run
    end

    def self.run_sessions(benchmark_run, duration, visitors)
      pool = Celluloid::Actor[:visitor_pool]
      futures = []
      visitors.times do
        futures << pool.future.run_session(benchmark_run, duration)
      end
      futures
    end

    def self.visitors_count(count)
      count = count || (Visitor.pool.size - 2)
      if count > 1
        count
      else
        1
      end
    end
  end
end
