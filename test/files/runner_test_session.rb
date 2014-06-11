CelluloidBenchmark::Session.define do
  benchmark :home_page, 1
  get "https://github.com/scottwillson/celluloid-benchmark"
end
