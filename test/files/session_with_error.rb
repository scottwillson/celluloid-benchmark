CelluloidBenchmark::Session.define do
  class FakePage
    def code
      503
    end
  end

  benchmark :home_page, 1
  raise Mechanize::ResponseCodeError.new(FakePage.new)
end
