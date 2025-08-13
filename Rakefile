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

  Rake::Task['default'].clear
  task default: [:rubocop, :rspec_with_retries, 'jasmine:ci']
  desc 'Run Brakeman'
  task :brakeman do
    sh('bundle exec brakeman')
  end
end
