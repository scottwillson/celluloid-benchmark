require "mechanize"
require "multi_json"
require "logger"
require_relative "data_sources"
require_relative "visitors/http_methods"

module CelluloidBenchmark
  # Actor that models a person using a web browser. Runs a test scenario. Delegates web browsing to
  # instance of a Mechanize Agent.
  class Visitor
    include Celluloid
    include CelluloidBenchmark::DataSources
    include CelluloidBenchmark::Visitors::HTTPMethods

    extend Forwardable

    def_delegators :@browser, :add_auth, :submit, :transact

    attr_accessor :benchmark_run
    attr_accessor :browser
    attr_accessor :current_request_label
    attr_accessor :current_request_threshold
    attr_accessor :request_start_time
    attr_accessor :request_end_time
    attr_reader :target

    def run_session(benchmark_run, duration, target = nil)
      @benchmark_run = benchmark_run
      @target = target

      elapsed_time = 0
      started_at = benchmark_run.started_at
      until elapsed_time >= duration
        begin
          add_new_browser
          Session.run self
        rescue Mechanize::ResponseCodeError => e
          log_response_code_error e
        rescue Errno::ETIMEDOUT, Net::ReadTimeout, Timeout::Error => e
          log_network_error e
        end

        elapsed_time = Time.now - started_at
      end
      elapsed_time
    end

    def add_new_browser
      @browser = Mechanize.new
      add_browser_timing_hooks
      @browser.user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/537.75.14"
      @browser.log = mechanize_logger
      @browser
    end

    def mechanize_logger
      @mechanize_logger ||= (
        logger = ::Logger.new("log/mechanize.log")
        logger.level = ::Logger::INFO
        logger
      )
    end

    def benchmark(label, threshold = 0.5)
      self.current_request_label = label
      self.current_request_threshold = threshold
    end

    def browser_type(value)
      case value
      when :iphone
        browser.user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"
      when :android
        browser.user_agent = "Mozilla/5.0 (Linux; Android 4.4; Nexus 5 Build/BuildID) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/30.0.0.0 Mobile Safari/537.36"
      when :ipad
        browser.user_agent = "Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"
      else
        browser.user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/537.75.14"
      end
    end

    def log_response(page)
      benchmark_run.async.log(
        page.code,
        request_start_time,
        request_end_time,
        server_response_time(page),
        current_request_label,
        current_request_threshold
      )

      true
    end

    def log_response_code_error(error)
      self.request_end_time = Time.now
      benchmark_run.async.log(
        error.response_code,
        request_start_time,
        request_end_time,
        server_response_time(browser.current_page),
        current_request_label,
        current_request_threshold
      )
      true
    end

    def log_network_error(error)
      self.request_end_time = Time.now
      benchmark_run.async.log(
        500,
        request_start_time,
        request_end_time,
        server_response_time(browser.current_page),
        current_request_label,
        current_request_threshold
      )
      true
    end


    private

    def add_browser_timing_hooks
      browser.pre_connect_hooks << proc do |agent, request|
        self.request_start_time = Time.now
      end

      browser.post_connect_hooks << proc do |agent, uri, response, body|
        self.request_end_time = Time.now
      end
    end

    def server_response_time(page)
      if page && page["x-runtime"]
        page["x-runtime"].to_f
      end
    end
  end
end
