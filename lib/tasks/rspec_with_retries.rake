require_relative 'support/rspec_rerunner'

desc "Run rspec tests, rerunning if anything fails"
task rspec_with_retries: :environment do
  RspecRerunner.new.run_tests
end
