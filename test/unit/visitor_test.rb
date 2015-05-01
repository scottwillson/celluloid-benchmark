require "minitest"
require "minitest/autorun"
require "celluloid"
require_relative "../../lib/celluloid_benchmark/benchmark_run"
require_relative "../../lib/celluloid_benchmark/session"
require_relative "../../lib/celluloid_benchmark/visitor"
require "fakeweb"

FakeWeb.allow_net_connect = false

module CelluloidBenchmark
  # Visitor#run_session is the central purpose of this gem, but best tested in an integration test,
  # not a unit test
  class VisitorTest < Minitest::Test
    class MockBrowser
      attr_accessor :requested_headers, :posted_json, :post_connect_hooks, :pre_connect_hooks, :putted_json, :user_agent, :uris

      def initialize
        @pre_connect_hooks = []
        @post_connect_hooks = []
        @posted_json = []
        @putted_json = []
        @requested_headers = []
        @uris = []
      end

      def get(uri, parameters = [], referer = nil, request_headers = {})
        uris << uri
        requested_headers << request_headers
      end

      def post(uri, query = nil, request_headers = {})
        uris << uri
        posted_json << query
        requested_headers << request_headers
      end

      def put(uri, query = nil, request_headers = {})
        uris << uri
        putted_json << query
        requested_headers << request_headers
      end
    end

    def setup
      # minitest and Celluloid both use at_exit
      Celluloid.boot
    end

    def test_run_session
      FakeWeb.register_uri(:get, "https://github.com/scottwillson/celluloid-benchmark", :body => "<html>OK</html>")

      browser = MockBrowser.new
      visitor = Visitor.new
      visitor.browser = browser

      require_relative "../files/runner_test_session.rb"

      benchmark_run = BenchmarkRun.new
      benchmark_run.mark_start
      elapsed_time = visitor.run_session(benchmark_run, 0.01)

      assert !elapsed_time.nil?, "elapsed_time should not be nil"
      assert elapsed_time > 0, "elapsed_time should be greater than zero, but was #{elapsed_time}"
    end

    def test_benchmark
      browser = MockBrowser.new
      visitor = Visitor.new
      visitor.browser = browser

      visitor.benchmark("purchase_page", 0.25)

      assert_equal "purchase_page", visitor.current_request_label, "current_request_label"
      assert_equal 0.25, visitor.current_request_threshold, "current_request_threshold"
    end

    def test_random_data
      browser = MockBrowser.new
      visitor = Visitor.new
      visitor.browser = browser

      data_sources = Minitest::Mock.new
      data_source = Minitest::Mock.new

      data_source.expect :sample, 3
      data_sources.expect :[], data_source, [ String ]

      visitor.data_sources = data_sources

      assert_equal 3, visitor.random_data("ids")
    end

    def test_delegate_put_and_post
      browser = MockBrowser.new
      visitor = Visitor.new
      visitor.browser = browser

      visitor.post "/"
      visitor.put "/", ""
    end

    def test_get_json
      browser = MockBrowser.new
      visitor = Visitor.new
      visitor.browser = browser

      visitor.get_json "/offers.json"
      assert_equal(
        [ { "Accept"=>"application/json, text/javascript, */*; q=0.01" } ],
        browser.requested_headers
      )
    end

    def test_post_json
      browser = MockBrowser.new
      visitor = Visitor.new
      visitor.browser = browser
      visitor.post_json "/mobile-api/v2/signup.json", { email: "person@example.com" }
      assert_equal(
        [ { "Accept"=>"application/json, text/javascript, */*; q=0.01", "Content-Type" => "application/json" } ],
        browser.requested_headers
      )
      assert_equal "{\"email\":\"person@example.com\"}", browser.posted_json.first
    end

    def test_post_json_with_headers
      browser = MockBrowser.new
      visitor = Visitor.new
      visitor.browser = browser
      visitor.post_json "/mobile-api/v2/signup.json", { email: "person@example.com" }, { "X-CSRF-Token" => "327yg" }
      assert_equal(
        [ { "Accept"=>"application/json, text/javascript, */*; q=0.01", "Content-Type" => "application/json", "X-CSRF-Token" => "327yg" } ],
        browser.requested_headers
      )
      assert_equal "{\"email\":\"person@example.com\"}", browser.posted_json.first
    end

    def test_put_json
      browser = MockBrowser.new
      visitor = Visitor.new
      visitor.browser = browser
      visitor.put_json "/offers.json", { price: "30.00" }
      assert_equal(
        [ { "Accept"=>"application/json, text/javascript, */*; q=0.01", "Content-Type" => "application/json" } ],
        browser.requested_headers
      )
      assert_equal "{\"price\":\"30.00\"}", browser.putted_json.first
    end

    def test_browser_type
      browser = MockBrowser.new
      visitor = Visitor.new
      visitor.browser = browser
      visitor.browser_type :mobile
    end

    def test_log_error_pages
      FakeWeb.register_uri(:get, "https://github.com/scottwillson/celluloid-benchmark", :body => "<html>OK</html>")

      browser = MockBrowser.new
      visitor = Visitor.new
      visitor.browser = browser

      require_relative "../files/session_with_error.rb"

      benchmark_run = BenchmarkRun.new
      benchmark_run.mark_start
      elapsed_time = visitor.run_session(benchmark_run, 0.01)

      assert !elapsed_time.nil?, "elapsed_time should not be nil"
      assert elapsed_time > 0, "elapsed_time should be greater than zero, but was #{elapsed_time}"
    end

    def test_log_network_error
      FakeWeb.register_uri(:get, "https://github.com/scottwillson/celluloid-benchmark", :body => "<html>OK</html>")

      browser = MockBrowser.new
      visitor = Visitor.new
      visitor.browser = browser

      require_relative "../files/session_with_network_error.rb"

      benchmark_run = BenchmarkRun.new
      benchmark_run.mark_start
      elapsed_time = visitor.run_session(benchmark_run, 0.01)

      assert !elapsed_time.nil?, "elapsed_time should not be nil"
      assert elapsed_time > 0, "elapsed_time should be greater than zero, but was #{elapsed_time}"
    end
  end
end