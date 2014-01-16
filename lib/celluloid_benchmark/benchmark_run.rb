require "logger"

require "celluloid"
require_relative "benchmark"

module CelluloidBenchmark
  # A test run of a scenario. Holds response times, codes, and requests. Reports results as an array of Benchmarks
  class BenchmarkRun
    include Celluloid

    attr_accessor :ended_at
    attr_accessor :logger
    attr_accessor :started_at
    attr_reader :thresholds

    def initialize
      if !Dir.exists?("log")
        FileUtils.mkdir "log"
      end
      
      # Could replace with Celluloid.logger
      @logger = ::Logger.new("log/benchmark.log")
      @thresholds = Hash.new
    end

    def log(http_status_code, start_time, end_time, label, threshold)
      time = end_time - start_time
      response_times[label] << time
      response_codes[label] << http_status_code.to_i
      
      if threshold
        thresholds[label] = threshold
      end
      
      logger.info "#{http_status_code} #{time} #{label}"
    end

    def response_times
      @response_times ||= Hash.new { |hash, value| hash[value] = [] }
    end

    def response_codes
      @response_codes ||= Hash.new { |hash, value| hash[value] = [] }
    end
  
    def requests
      response_times.values.compact.map(&:size).reduce(0, &:+)
    end
    
    def benchmarks
      response_times.map do |label, response_times|
        CelluloidBenchmark::Benchmark.new label, thresholds[label], response_times, response_codes[label]
      end
    end
    
    def mark_start
      @started_at = Time.now
    end
    
    def mark_end
      @ended_at = Time.now
    end
    
    def elapsed_time
      if started_at && ended_at
        (ended_at - started_at).to_f
      else
        0
      end
    end
  
    def ok?
      benchmarks.all?(&:ok?)
    end

    def inspect
      response_times.map do |label, response_times|
        "#{label} #{response_times.reduce(:+) / response_times.size} #{response_times.min} #{response_times.max} #{response_times.size}"
      end
    end
  end
end
