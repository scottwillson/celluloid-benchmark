source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Duplication with gemspec but I like to explicitly require gems

gem "celluloid", require: false
gem "mechanize", require: false
gem "mime-types", require: false
gem "multi_json", require: false
gem "rake", require: false
gem "slop", "~> 4", require: false
gem "table_print", require: false

platform :rbx do
  # MRI includes by default, but Rubinius does not
  gem "racc"
end

group :development do
  gem "rubocop", require: false
end

group :test do
  gem "minitest", require: false
  gem "rack-contrib", require: false
  gem "webmock"

  # Thin requires Ruby standard libs that
  # Rubinius does not provide by default
  gem "rubysl-logger", platform: :rbx
  gem "rubysl-optparse", platform: :rbx
  gem "rubysl-open3", platform: :rbx
  gem "rubysl-singleton", platform: :rbx
  gem "rubysl-mutex_m", platform: :rbx

  gem "thin", require: false
  gem "timecop", require: false
end
