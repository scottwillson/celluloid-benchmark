module CelluloidBenchmark
  module DataSources
    def random_data(key)
      data_source(key).sample
    end

    def data_sources
      @data_sources ||= Hash.new do |hash, key|
        hash[key] = File.readlines("tmp/data/#{key}s.csv").map(&:strip)
      end
    end

    def data_sources=(hash)
      @data_sources = hash
    end

    def data_source(key)
      raise_empty(key) if empty?(key)
      data_sources[key]
    end

    def raise_empty(key)
      raise "Empty random data for '#{key}'. Ensure target has test data and run rake app:performance:get_random_data."
    end

    def empty?(key)
      data_sources[key].size == 0
    end
  end
end

