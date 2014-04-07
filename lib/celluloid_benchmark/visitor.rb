require "mechanize"
require_relative "data_sources"

module CelluloidBenchmark
  # Actor that models a person using a web browser. Runs a test scenario. Delegates web browsing to
  # instance of a Mechanize Agent.
  class Visitor
    include Celluloid
    include CelluloidBenchmark::DataSources

    extend Forwardable

    def_delegators :@browser, :add_auth, :get, :post, :put, :submit, :transact

    attr_reader :benchmark_run
    attr_reader :browser
    attr_accessor :current_request_label
    attr_accessor :current_request_threshold
    attr_accessor :request_start_time
    attr_accessor :request_end_time

    def initialize(browser = Mechanize.new)
      @browser = browser
      add_browser_timing_hooks
    end

    def run_session(session, benchmark_run, duration)
      @benchmark_run = benchmark_run

      elapsed_time = 0
      started_at = Time.now
      until elapsed_time >= duration
        begin
          instance_eval session
        rescue Mechanize::ResponseCodeError => e
          log_response_code_error e
        end

        elapsed_time = Time.now - started_at
      end
      elapsed_time
    end

    def benchmark(label, threshold = 0.5)
      self.current_request_label = label
      self.current_request_threshold = threshold
    end


    private

    def add_browser_timing_hooks
      browser.pre_connect_hooks << proc do |agent, request|
        self.request_start_time = Time.now
      end

      browser.post_connect_hooks << proc do |agent, uri, response, body|
        self.request_end_time = Time.now
        benchmark_run.async.log response.code, request_start_time, request_end_time, current_request_label, current_request_threshold
      end
    end

    def log_response_code_error(error)
      self.request_end_time = Time.now
      benchmark_run.async.log(
        error.response_code,
        request_start_time,
        request_end_time,
        current_request_label,
        current_request_threshold
      )
    end
  end
end
