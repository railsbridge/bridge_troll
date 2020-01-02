#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

require "rubocop/rake_task"
RuboCop::RakeTask.new

Rails.application.load_tasks

if Rails.env.development? || Rails.env.test?
  Rake::Task["default"].clear
  task default: [:rubocop, :rspec_with_retries, "jasmine:ci"]
end
