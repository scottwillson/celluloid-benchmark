CelluloidBenchmark::Session.define do
  benchmark :home_page, 1
  get "https://bespoke-preprod.analoganalytics.com"
end
