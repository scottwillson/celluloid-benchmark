CelluloidBenchmark::Session.define do
  class FakePageWithError
    def code
      503
    end
  end

  benchmark :home_page, 1
  raise Mechanize::ResponseCodeError.new(FakePageWithError.new)
end
