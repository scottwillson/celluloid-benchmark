require "celluloid"
require_relative "visitor_group"

Celluloid.logger = nil

module CelluloidBenchmark
  # Run a scenario in several Visitors and return a BenchmarkRun
  class Runner
    def self.run(session_path, duration = 10)
      raise("session_path is required") unless session_path
      raise("'#{session_path}' does not exist") unless File.exists?(session_path)

      visitor_group = VisitorGroup.run!
      benchmark_run = Celluloid::Actor[:benchmark_run]

      benchmark_run.mark_start
      futures = run_sessions(session_path, benchmark_run, duration)
      futures.map(&:value)
      benchmark_run.mark_end

      benchmark_run
    end

    def self.run_sessions(session_path, benchmark_run, duration)
      session = File.read(session_path)
      visitors = Celluloid::Actor[:visitor_pool]
      futures = []
      (visitors.size - 2).times do
        futures << visitors.future.run_session(session, benchmark_run, duration)
      end
      futures
    end
  end
end
