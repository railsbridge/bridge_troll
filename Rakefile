#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rubocop/rake_task'

Bridgetroll::Application.load_tasks

# Run RuboCop lint along with specs
if %w{development test}.include? Rails.env
  RuboCop::RakeTask.new(:rubocop)
  task default: [:rubocop, :spec]
end
