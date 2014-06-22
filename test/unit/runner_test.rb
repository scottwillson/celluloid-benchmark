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
      FakeWeb.register_uri(:get, "https://github.com/scottwillson/celluloid-benchmark", :body => "<html>OK</html>")
      benchmark_run = Runner.run(File.dirname(__FILE__) + "/../files/runner_test_session.rb", 0.1)

      benchmarks = benchmark_run.benchmarks
      assert_equal 1, benchmarks.size
      benchmark = benchmarks.first
      assert benchmark.ok?, "benchmark.ok?"
    end

    def test_run_with_visitors_arg
      FakeWeb.register_uri(:get, "https://github.com/scottwillson/celluloid-benchmark", :body => "<html>OK</html>")
      benchmark_run = Runner.run(File.dirname(__FILE__) + "/../files/runner_test_session.rb", 0.1, "12")

      benchmarks = benchmark_run.benchmarks
      assert_equal 1, benchmarks.size
      benchmark = benchmarks.first
      assert benchmark.ok?, "benchmark.ok?"
    end
  end
end
