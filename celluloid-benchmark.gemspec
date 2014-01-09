# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "celluloid_benchmark/version"

Gem::Specification.new do |spec|
  spec.name        = "celluloid-benchmark"
  spec.version     = CelluloidBenchmark::VERSION
  spec.license     = "MIT"
  spec.summary     = "Pure Ruby, realistic, website load test tool"
  spec.description = "Celluloid Benchmark realistically load tests websites. Write expressive, concise load tests in Ruby. Use Rubinius and Celluloid
forpec high concurrency. Use Mechanize for a realistic (albeit non-JavaScript) browser client."
  spec.author      = "Scott Willson"
  spec.email       = "scott.willson@gmail.com"
  spec.files       = Dir[ "lib/*.rb" ] + [ "LICENSE", "README.md" ] + Dir[ "bin/*" ]
  spec.homepage    = "https://github.com/scottwillson/celluloid-benchmark"

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = Dir[ "test/**/*" ]
  spec.require_paths = [ "lib" ]

  # Duplication with Gemfile but I like to explicitly require gems
  spec.add_runtime_dependency "celluloid", "~> 0.15"
  spec.add_runtime_dependency "mechanize", "~> 2.7"
  spec.add_runtime_dependency "racc", "~> 1"
end
