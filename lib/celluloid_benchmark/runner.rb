require "celluloid"
require_relative "session"
require_relative "target"
require_relative "visitor_group"

Celluloid.logger = nil

module CelluloidBenchmark
  # Run a scenario in several Visitors and return a BenchmarkRun
  class Runner
    def self.run(session_path = nil, duration = nil, visitors = nil, target = nil)
      session_path ||= "session.rb"
      session_path = File.expand_path(session_path)
      require session_path

      VisitorGroup.run!

      visitors = visitors_count(visitors)
      benchmark_run = Celluloid::Actor[:benchmark_run]
      benchmark_run.visitors = visitors

      benchmark_run.mark_start
      futures = run_sessions(benchmark_run, duration || 20, visitors, Target.new_from_key(target))
      futures.map(&:value)

      benchmark_run.mark_end

      benchmark_run
    end

    def self.run_sessions(benchmark_run, duration, visitors, target)
      pool = Celluloid::Actor[:visitor_pool]
      futures = []
      visitors.times do
        futures << pool.future.run_session(benchmark_run, duration, target)
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
