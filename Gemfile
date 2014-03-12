source "https://rubygems.org"

# Duplication with gemspec but I like to explicitly require gems

gem "celluloid", "~> 0.15", require: false
gem "mechanize", "~> 2.7", require: false
gem "mime-types", "~> 1.16", require: false
gem "rake", require: false

group :rbx do
  # MRI includes by default, but Rubinius does not
  gem "racc"
end

group :test do
  gem "fakeweb", require: false
  gem "minitest", require: false
  gem "rack-contrib", require: false

  # Thin requires Ruby standard libs that
  # Rubinius does not provide by default
  gem "rubysl-logger"
  gem "rubysl-optparse"
  gem "rubysl-open3"
  gem "rubysl-singleton"
  gem "rubysl-mutex_m"
  gem "thin", require: false
  gem "timecop", require: false
end
