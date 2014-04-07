require "minitest"
require "minitest/autorun"
require "celluloid"
require_relative "../../lib/celluloid_benchmark/visitor"

module CelluloidBenchmark
  # Visitor#run_session is the central purpose of this gem, but best tested in an integration test,
  # not a unit test
  class VisitorTest < Minitest::Test
    class MockBrowser
      attr_accessor :post_connect_hooks, :pre_connect_hooks, :uris

      def initialize
        @pre_connect_hooks = []
        @post_connect_hooks = []
        @uris = []
      end

      def get(uri)
        uris << uri
      end

      def post(uri)
        uris << uri
      end

      def put(uri)
        uris << uri
      end
    end

    def setup
      # minitest and Celluloid both use at_exit
      Celluloid.boot
    end

    def test_run_session
      browser = MockBrowser.new
      visitor = Visitor.new(browser)
      session = File.read(File.dirname(__FILE__) + "/../files/runner_test_session.rb")

      elapsed_time = visitor.run_session(session, nil, 0.01)

      assert !elapsed_time.nil?, "elapsed_time should not be nil"
      assert elapsed_time > 0, "elapsed_time should be greater than zero, but was #{elapsed_time}"
    end

    def test_benchmark
      browser = MockBrowser.new
      visitor = Visitor.new(browser)

      visitor.benchmark("purchase_page", 0.25)

      assert_equal "purchase_page", visitor.current_request_label, "current_request_label"
      assert_equal 0.25, visitor.current_request_threshold, "current_request_threshold"
    end

    def test_random_data
      browser = MockBrowser.new
      visitor = Visitor.new(browser)

      data_sources = Minitest::Mock.new
      data_source = Minitest::Mock.new

      data_source.expect :sample, 3
      data_sources.expect :[], data_source, [ String ]

      visitor.data_sources = data_sources

      assert_equal 3, visitor.random_data("ids")
    end

    def test_delegate_put_and_post
      browser = MockBrowser.new
      visitor = Visitor.new(browser)
      visitor.post "/"
      visitor.put "/"
    end
  end
end