require 'yaml'
require_relative 'failure_file_parser'

class RspecRerunner
  RERUN_ATTEMPTS = ENV.fetch('RERUN_ATTEMPTS', 3).to_i
  RERUN_THRESHOLD = ENV.fetch('RERUN_THRESHOLD', 5).to_i

  def initialize
    @failure_file_parser = FailureFileParser.new(
      Rails.root.join('tmp', 'rspec_examples.txt')
    )
  end

  def run_tests
    Bundler.with_clean_env do
      succeeded_initially = system("bundle exec rake parallel:spec")
      return if succeeded_initially
    end

    failure_count = @failure_file_parser.failures_from_persistence_file.length
    if failure_count > RERUN_THRESHOLD
      puts "#{failure_count} tests failed, first run, which is over the rerun threshold of #{RERUN_THRESHOLD}"
      exit 1
    end

    RERUN_ATTEMPTS.times do
      Bundler.with_clean_env do
        succeeded_on_retry = system("SPEC_OPTS='--only-failures' bundle exec rake parallel:spec")
        return if succeeded_on_retry
      end
    end

    puts "TESTS HAVE FAILED AFTER #{RERUN_ATTEMPTS} RETRIES!"
    exit 1
  end
end
