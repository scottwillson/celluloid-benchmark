require "celluloid"
require_relative "session"
require_relative "visitor_group"

Celluloid.logger = nil

module CelluloidBenchmark
  # Run a scenario in several Visitors and return a BenchmarkRun
  class Runner
    def self.run(session_path, duration = 10, visitors = nil)
      raise("session_path is required") unless session_path
      raise("'#{session_path}' does not exist") unless File.exists?(session_path)

      require session_path

      VisitorGroup.run!
      set_visitors_pool_size visitors
      benchmark_run = Celluloid::Actor[:benchmark_run]

      benchmark_run.mark_start
      futures = run_sessions(benchmark_run, duration)
      futures.map(&:value)
      benchmark_run.mark_end

      benchmark_run
    end

    def self.run_sessions(benchmark_run, duration)
      visitors = Celluloid::Actor[:visitor_pool]
      futures = []
      (visitors.size - 2).times do
        futures << visitors.future.run_session(benchmark_run, duration)
      end
      futures
    end

    def self.set_visitors_pool_size(size)
      if size && size.to_i > 0
        Visitor.pool.size = size.to_i + 2
      end
    end
  end
end
