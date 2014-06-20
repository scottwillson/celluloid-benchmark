source "https://rubygems.org"

# Duplication with gemspec but I like to explicitly require gems

gem "celluloid", "~> 0.16.0.pre", git: "https://github.com/celluloid/celluloid.git", require: false
gem "mechanize", "~> 2.7", require: false
gem "mime-types", "~> 1.25", require: false
gem "multi_json", require: false
gem "rake", require: false

platform :rbx do
  # MRI includes by default, but Rubinius does not
  gem "racc"
end

group :test do
  gem "fakeweb", require: false
  gem "minitest", require: false
  gem "rack-contrib", require: false

  # Thin requires Ruby standard libs that
  # Rubinius does not provide by default
  gem "rubysl-logger", platform: :rbx
  gem "rubysl-optparse", platform: :rbx
  gem "rubysl-open3", platform: :rbx
  gem "rubysl-singleton", platform: :rbx
  gem "rubysl-mutex_m", platform: :rbx
  gem "thin", require: false, platform: :rbx
  gem "timecop", require: false
end
