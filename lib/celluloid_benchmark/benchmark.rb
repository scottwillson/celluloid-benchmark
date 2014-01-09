module CelluloidBenchmark
  # List of responses for a benchmark defined in test scenario.
  #
  # For example, requests for /offers/1001, /offers/1001-burgerville-deal, /offers/2200 
  # might all be grouped under the "offer_show" label
  #
  # Call #ok? to check that responses were OK and fast enough.
  class Benchmark
    attr_reader :label
    attr_reader :response_codes
    attr_reader :response_times
    attr_reader :threshold

    def initialize(label, threshold, response_times, response_codes)
      raise(ArgumentError, "label cannot be blank") if label.nil? || label == ""

      @label = label
      @response_times = response_times || []
      @threshold = threshold || 3.0
      @response_codes = response_codes || []

      raise(ArgumentError, "threshold must be greater than zero") if self.threshold <= 0
    end
    
    def ok?
      response_times_ok? && response_codes_ok?
    end

    # Consider average response time. Do not check for outlying slow times.
    def response_times_ok?
      if response_times.size > 0
        average_response_time <= threshold
      else
        true
      end
    end

    # 200 OK is ... OK, as is a redirect, not modified, or auth required
    def response_codes_ok?
      response_codes.all? { |code| code == 200 || code == 302 || code == 304 || code == 401 }
    end
    
    
    private
    
    def average_response_time
      response_times.reduce(:+) / response_times.size
    end
  end
end
