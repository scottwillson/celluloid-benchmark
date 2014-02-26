require "minitest"
require "minitest/autorun"
require_relative "../../lib/celluloid_benchmark/benchmark"

module CelluloidBenchmark
  class BenchmarkTest < Minitest::Test
    def test_require_label
      assert_raises ArgumentError do
        Benchmark.new(nil, 1, [], [])
      end
    end
    
    def test_require_threshold_above_zero
      assert_raises ArgumentError do
        Benchmark.new("homepage", 0, nil, nil)
      end
    end
    
    def test_defaults
      benchmark = Benchmark.new("homepage", nil, nil, nil)
      
      assert_equal 3, benchmark.threshold, "default threshold"

      assert !benchmark.response_codes.nil?, "response_codes default"
      assert benchmark.response_codes.empty?, "response_codes default"

      assert !benchmark.response_times.nil?, "response_times default"
      assert benchmark.response_times.empty?, "response_times default"
    end
    
    def test_response_times_ok_for_empty_benchmark
      benchmark = Benchmark.new("homepage", nil, nil, nil)
      assert benchmark.ok?, "Empty Benchmark should be OK"
    end

    def test_ok_if_response_codes_and_times_ok
      benchmark = Benchmark.new("homepage", nil, nil, nil)
      
      benchmark.stub(:response_times_ok?, true) do
        benchmark.stub(:response_codes_ok?, true) do
          assert benchmark.ok?, "Benchmark.ok? times OK and codes OK"
        end
      end
      
      benchmark.stub(:response_times_ok?, false) do
        benchmark.stub(:response_codes_ok?, true) do
          assert !benchmark.ok?, "Benchmark.ok? times not OK and codes OK"
        end
      end
      
      benchmark.stub(:response_times_ok?, true) do
        benchmark.stub(:response_codes_ok?, false) do
          assert !benchmark.ok?, "Benchmark.ok? times OK and codes not OK"
        end
      end
      
      benchmark.stub(:response_times_ok?, false) do
        benchmark.stub(:response_codes_ok?, false) do
          assert !benchmark.ok?, "Benchmark.ok? times not OK and codes not OK"
        end
      end
    end
    
    def test_blank_response_time_ok
      benchmark = Benchmark.new("homepage", nil, nil, nil)
      assert benchmark.response_times_ok?
    end
    
    def test_blank_response_codes_ok
      benchmark = Benchmark.new("homepage", nil, nil, nil)
      assert benchmark.response_codes_ok?
    end
    
    def test_response_times
      benchmark = Benchmark.new("test", 1, [ 0.99, 0.9, 1.01 ], nil)
      assert benchmark.response_times_ok?

      benchmark = Benchmark.new("test", 1, [ 1.000001, 1, 1 ], nil)
      assert !benchmark.response_times_ok?
    end
    
    def test_response_codes
      benchmark = Benchmark.new("test", nil, [], [])
      assert benchmark.response_codes_ok?

      benchmark = Benchmark.new("test", nil, [], [ 500 ])
      assert !benchmark.response_codes_ok?

      benchmark = Benchmark.new("test", nil, [], [ 200 ])
      assert benchmark.response_codes_ok?

      benchmark = Benchmark.new("test", nil, [], [ 200, 500 ])
      assert !benchmark.response_codes_ok?

      benchmark = Benchmark.new("test", nil, [], [ 200, 302, 304, 401 ])
      assert benchmark.response_codes_ok?

      benchmark = Benchmark.new("test", nil, [], [ 403, 200, 302, 401 ])
      assert !benchmark.response_codes_ok?

      benchmark = Benchmark.new("test", nil, [], [ 410, 200, 302, 401 ])
      assert !benchmark.response_codes_ok?

      benchmark = Benchmark.new("test", nil, [], [ 309, 200, 302, 401 ])
      assert !benchmark.response_codes_ok?
    end
  end
end
