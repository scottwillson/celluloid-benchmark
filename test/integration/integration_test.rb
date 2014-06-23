require "minitest"
require "minitest/autorun"
require_relative "../../lib/celluloid_benchmark"

module CelluloidBenchmark
  class IntegrationTest < Minitest::Test
    def setup
      # minitest and Celluloid both use at_exit
      Celluloid.boot

      start_target_webserver
    end

    def teardown
      stop_target_webserver
    end

    def test_happy_path
      assert target_webserver_responsive?, "Test web server did not respond OK"

      session_path = File.expand_path(File.dirname(__FILE__) + "/test_session.rb")
      duration = 5
      benchmark_run = CelluloidBenchmark::Runner.run(session: session_path, duration: duration)

      assert benchmark_run.ok?, "Run should be OK"
    end

    def start_target_webserver
      `thin --threaded --rackup test/integration/config.ru --daemonize --port 8000 start`
    end

    def stop_target_webserver
      `thin stop`
    end

    def target_webserver_responsive?
      require "net/http"
      require "uri"

      uri = URI.parse("http://localhost:8000/")
      http = Net::HTTP.new(uri.host, uri.port)
      Timeout::timeout(5) do
        request = Net::HTTP::Get.new(uri.request_uri)
        begin
          response = http.request(request)
          if response.code.to_i == 200
            return true
          end
        rescue Errno::ECONNREFUSED, Net::HTTP::Persistent::Error
          # Ignore. Server might be starting up.
        end
        sleep 1
      end
    end
  end
end
