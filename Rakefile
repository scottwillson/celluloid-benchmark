require "rake/testtask"

desc "Run all tests"
task default: :test

task test: [ "test:unit", "test:integration" ]

namespace :test do
  Rake::TestTask.new(:integration) do |t|
    t.test_files = FileList["test/integration/**/*test.rb"]
    t.warning = false
  end

  Rake::TestTask.new(:unit) do |t|
    t.test_files = FileList["test/unit/**/*test.rb"]
    t.warning = false
  end
end
