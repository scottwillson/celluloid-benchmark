CelluloidBenchmark::Session.define do
  benchmark :home_page, 1
  get "http://localhost:8000/"
end
