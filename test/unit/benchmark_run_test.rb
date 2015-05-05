require "minitest"
require "minitest/autorun"
require "timecop"
require_relative "../../lib/celluloid_benchmark/benchmark_run"

module CelluloidBenchmark
  class BenchmarkRunTest < Minitest::Test
    def setup
      # minitest and Celluloid both use at_exit
      Celluloid.boot
    end

    def test_new
      BenchmarkRun.new
    end

    def test_inspect
      BenchmarkRun.new.inspect
    end

    def test_log
      benchmark_run = BenchmarkRun.new
      logger = Minitest::Mock.new
      logger.expect :info, true, [ "200 4 search"]
      benchmark_run.logger = logger
      benchmark_run.log 200, 1, 2, 4, "search", 3
    end

    def test_response_times
      benchmark_run = BenchmarkRun.new
      assert_equal Hash.new, benchmark_run.response_times

      benchmark_run.log 200, 3, 4, 0.1, "search", 0
      assert_equal({ "search" => [ 0.1 ] }, benchmark_run.response_times)

      benchmark_run.log 200, 40, 100, 10, "search", 3
      search_times = benchmark_run.response_times[ "search" ]
      assert_equal [ 0.1, 10 ], search_times.sort

      benchmark_run.log 404, 1000, 2000, 90, "home", 3
      search_times = benchmark_run.response_times[ "search" ]
      assert_equal [ 0.1, 10 ], search_times.sort
      assert_equal [ 90 ], benchmark_run.response_times[ "home" ]
    end

    def test_response_codes
      benchmark_run = BenchmarkRun.new
      assert_equal Hash.new, benchmark_run.response_codes

      benchmark_run.log 200, 3, 4, 5, "search", 0
      assert_equal({ "search" => [ 200 ] }, benchmark_run.response_codes)

      benchmark_run.log 302, 40, 100, 5, "search", 3
      search_codes = benchmark_run.response_codes[ "search" ]
      assert_equal [ 200, 302 ], search_codes.sort

      benchmark_run.log 404, 1000, 2000, 5, "home", 3
      search_codes = benchmark_run.response_codes[ "search" ]
      assert_equal [ 200, 302 ], search_codes.sort
      assert_equal [ 404 ], benchmark_run.response_codes[ "home" ]
    end

    def test_requests
      benchmark_run = BenchmarkRun.new
      assert_equal 0, benchmark_run.requests

      benchmark_run.log 200, 3, 4, 5, "search", 0
      assert_equal 1, benchmark_run.requests

      benchmark_run.log 200, 3, 4, 5, "search", 0
      assert_equal 2, benchmark_run.requests
    end

    def test_benchmarks
      benchmark_run = BenchmarkRun.new
      assert_equal 0, benchmark_run.benchmarks.size
      assert benchmark_run.benchmarks.empty?

      benchmark_run.log 200, 3, 4, 0.011, "search", 0.01
      assert_equal 1, benchmark_run.benchmarks.size
      benchmark = benchmark_run.benchmarks.first
      assert_equal "search", benchmark.label, "benchmark label"
      assert_equal 0.01, benchmark.threshold, "benchmark threshold"
      assert_equal [ 0.011 ], benchmark.response_times, "benchmark response_times"
      assert_equal [ 200 ], benchmark.response_codes, "benchmark response_codes"
    end

    def test_mark_start
      benchmark_run = BenchmarkRun.new
      assert_equal nil, benchmark_run.started_at, "started_at"

      Timecop.freeze(Time.new(2001, 4, 5, 18, 30)) do
        benchmark_run.mark_start
      end

      assert_equal Time.new(2001, 4, 5, 18, 30), benchmark_run.started_at
    end

    def test_mark_end
      benchmark_run = BenchmarkRun.new
      assert_equal nil, benchmark_run.ended_at, "ended_at"

      Timecop.freeze(Time.new(2001, 4, 5, 18, 30)) do
        benchmark_run.mark_end
      end

      assert_equal Time.new(2001, 4, 5, 18, 30), benchmark_run.ended_at
    end

    def test_ok
      benchmark_run = BenchmarkRun.new
      assert benchmark_run.ok?

      benchmark_run.stub :benchmarks, [ Minitest::Mock.new.expect(:ok?, true) ] do
        assert benchmark_run.ok?
      end

      benchmark_run.stub :benchmarks, [ Minitest::Mock.new.expect(:ok?, true), Minitest::Mock.new.expect(:ok?, true) ] do
        assert benchmark_run.ok?
      end

      benchmark_run.stub :benchmarks, [ Minitest::Mock.new.expect(:ok?, false), Minitest::Mock.new.expect(:ok?, true) ] do
        assert !benchmark_run.ok?
      end

      benchmark_run.stub :benchmarks, [ Minitest::Mock.new.expect(:ok?, false), Minitest::Mock.new.expect(:ok?, false) ] do
        assert !benchmark_run.ok?
      end
    end

    def test_network_time
      benchmark_run = BenchmarkRun.new
      assert_equal Hash.new, benchmark_run.network_times

      benchmark_run.log 200, 3, 4, 0.1, "search", 0
      assert_equal({ "search" => [ 0.9 ] }, benchmark_run.network_times)
      assert_equal 0.9, benchmark_run.network_time
    end
  end
end