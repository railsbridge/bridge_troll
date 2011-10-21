ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/dsl'
require 'selenium-webdriver'
require 'faker'
require 'rake'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

module RSpec::Core
  class ExampleGroup
    include Capybara::DSL
  end
end

Capybara.configure do |config|
  config.default_driver = :selenium
  config.default_selector = :css
end

RSpec.configure do |config|
  config.include(Capybara, :type => :integration)
  config.before :each do
    ActiveRecord::Base.send(:descendants).each do |klass|
      klass.destroy_all
    end

    load 'db/seeds.rb'
  end
end
