require "minitest"
require "minitest/autorun"
require_relative "../../lib/celluloid_benchmark/session"

module CelluloidBenchmark
  class SessionTest < Minitest::Test
    def setup
      # minitest and Celluloid both use at_exit
      Celluloid.boot
    end

  end
end
