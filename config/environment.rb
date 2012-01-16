# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
BridgeTroll::Application.initialize!

# Optionally require the debugger
if Rails.env == "development"
  require "ruby-debug" 
  Debugger.start
  Debugger.settings[:autoeval] = true
end
