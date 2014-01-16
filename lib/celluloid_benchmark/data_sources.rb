module CelluloidBenchmark
  module DataSources
    def random_data(key)
      data_source(key).sample
    end
    
    def data_sources
      @data_sources ||= Hash.new do |hash, key|
        hash[key] = File.readlines("tmp/data/#{key}s.csv")
      end
    end
    
    def data_sources=(hash)
      @data_sources = hash
    end

    def data_source(key)
      data_sources[key]
    end
  end
end

