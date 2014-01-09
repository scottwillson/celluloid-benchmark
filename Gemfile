source "https://rubygems.org"

# Duplication with gemspec but I like to explicitly require gems

gem "celluloid", "~> 0.15", require: false
gem "mechanize", "~> 2.7", require: false
# MRI includes by default, but Rubinius does not
gem "racc"

group :test do
  gem "fakeweb", require: false
  gem "minitest", require: false
  gem "rack-contrib", require: false

  # Thin requires Ruby standard libs that
  # Rubinius does not provide by default
  gem "rubysl-logger"
  gem "rubysl-optparse"
  gem "rubysl-open3"
  gem "thin", require: false
  gem "timecop", require: false
end
