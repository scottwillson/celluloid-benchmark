require "minitest"
require "minitest/autorun"
require_relative "../../lib/celluloid_benchmark/benchmark_run"
require_relative "../../lib/celluloid_benchmark/text_formatter"

module CelluloidBenchmark
  class TextFormatterTest < Minitest::Test
    def setup
      # minitest and Celluloid both use at_exit
      Celluloid.boot
    end

    def test_empy
      benchmark_run = BenchmarkRun.new
      silence_streams(STDOUT) do
        CelluloidBenchmark::TextFormatter.to_s(benchmark_run)
      end
    end

    def test_to_s
      benchmark_run = BenchmarkRun.new
      benchmark_run.log 200, 3, 4, 0.1, "search", 1

      silence_streams(STDOUT) do
        CelluloidBenchmark::TextFormatter.to_s(benchmark_run)
      end
    end

    def silence_streams(*streams)
      on_hold = streams.collect { |stream| stream.dup }
      streams.each do |stream|
        stream.reopen(RUBY_PLATFORM =~ /mswin/ ? 'NUL:' : '/dev/null')
        stream.sync = true
      end
      yield
    ensure
      streams.each_with_index do |stream, i|
        stream.reopen(on_hold[i])
      end
    end
  end
end
