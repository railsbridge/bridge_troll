#!/usr/bin/env rake
# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('config/application', __dir__)

Rails.application.load_tasks

if Rails.env.local?
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new.tap do |task|
    task.options = %w[--parallel]
  end

  desc 'Run Brakeman'
  task brakeman: :environment do
    sh('bundle exec brakeman')
  end

  # these two tasks cannot be run in parallel because there's contention over sprockets cache
  task all_tests: %w[jasmine:ci rspec_with_retries]

  multitask faster_default: %w[rubocop brakeman all_tests]

  # need to clear because the default task is already defined as a Task not a MultiTask
  task(:default).clear.enhance([:faster_default])
end
