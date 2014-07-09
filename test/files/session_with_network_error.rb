CelluloidBenchmark::Session.define do
  benchmark :home_page, 1
  raise Errno::ETIMEDOUT
end
