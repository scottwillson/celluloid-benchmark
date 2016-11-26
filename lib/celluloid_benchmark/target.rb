module CelluloidBenchmark
  class Target
    attr_reader :http_auth_password
    attr_reader :http_auth_username
    attr_reader :key
    attr_reader :uri

    def self.new_from_key(key, config_file_path = nil)
      key ||= "local"
      config_file_path ||= "config/targets.yml"

      if key == "local" && !File.exist?(config_file_path)
        return default_target
      end

      configs = YAML.load_file(config_file_path)
      config = configs[key]

      unless config
        raise ArgumentError, "No target for '#{key}'"
      end

      if config["http_auth"]
        Target.new(key, config["uri"], config["http_auth"]["username"], config["http_auth"]["password"])
      else
        Target.new(key, config["uri"])
      end
    end

    def self.default_target
      Target.new("local", "http://localhost")
    end

    def initialize(key, uri, http_auth_username = nil, http_auth_password = nil)
      @http_auth_password = http_auth_password
      @http_auth_username = http_auth_username
      @key = key
      @uri = uri
    end

    def http_auth?
      http_auth_username && http_auth_password
    end
  end
end
