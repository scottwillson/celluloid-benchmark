require "minitest"
require "minitest/autorun"
require_relative "../../lib/celluloid_benchmark/runner"
require "fakeweb"

FakeWeb.allow_net_connect = false

module CelluloidBenchmark
  class BenchmarkRunnerTest < Minitest::Test
    def setup
      # minitest and Celluloid both use at_exit
      Celluloid.boot
    end

    def test_run
      FakeWeb.register_uri(:get, "https://github.com/scottwillson/celluloid-benchmark", :body => "<html>OK</html>", "x-runtime" => 0.173)
      benchmark_run = Runner.run(session: File.dirname(__FILE__) + "/../files/runner_test_session.rb", duration: 0.2)

      benchmarks = benchmark_run.benchmarks
      assert_equal 1, benchmarks.size
      benchmark = benchmarks.first
      assert benchmark.ok?, "benchmark.ok?"
      assert_in_delta 0.173, benchmark.average_response_time, 0.001, "response times should be calculated from x-runtime"
    end

    def test_run_with_visitors_arg
      FakeWeb.register_uri(:get, "https://github.com/scottwillson/celluloid-benchmark", :body => "<html>OK</html>")
      benchmark_run = Runner.run(session: File.dirname(__FILE__) + "/../files/runner_test_session.rb", duration: 0.2, visitors: "12")

      benchmarks = benchmark_run.benchmarks
      assert_equal 1, benchmarks.size
      benchmark = benchmarks.first
      assert benchmark.ok?, "benchmark.ok?"
      assert benchmark.average_response_time > 0, "response times should be calculated without x-runtime"
    end
  end
end