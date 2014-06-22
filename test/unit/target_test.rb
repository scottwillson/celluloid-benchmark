require "minitest"
require "minitest/autorun"
require_relative "../../lib/celluloid_benchmark/target"

module CelluloidBenchmark
  class TargetTest < Minitest::Test
    def test_new_from_key
      assert_equal Target.new_from_key(nil, "test/files/targets.yml").key, "local"
      assert_equal Target.new_from_key("dev", "test/files/targets.yml").key, "dev"
      assert_raises(ArgumentError) { Target.new_from_key("production", "test/files/targets.yml") }
    end

    def test_http_auth
      target = Target.new_from_key(nil, "test/files/targets.yml")
      assert !target.http_auth?, "no username + no password == no http auth"
    end

    def test_uri
      target = Target.new_from_key("dev", "test/files/targets.yml")
      assert_equal "https://devel.digitaloffersengineering.com", target.uri
    end

    def test_use_default_target
      target = Target.new_from_key(nil, nil)
      assert_equal "http://localhost", target.uri
    end
  end
end
