module CelluloidBenchmark
  module Session
    @session_block = nil

    def self.define(&block)
      @session_block = block
    end

    def self.run(visitor)
      visitor.instance_eval(&@session_block)
    end
  end
end
