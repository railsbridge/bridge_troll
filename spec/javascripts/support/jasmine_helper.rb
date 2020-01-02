# frozen_string_literal: true

# Use this file to set/override Jasmine configuration options
# You can remove it if you don't need it.
# This file is loaded *after* jasmine.yml is interpreted.
#
# Example: using a different boot file.
# Jasmine.configure do |config|
#   config.boot_dir = '/absolute/path/to/boot_dir'
#   config.boot_files = lambda { ['/absolute/path/to/boot_dir/file.js'] }
# end
#

Rails.application.config.assets.precompile += %w[jasmine-jquery.js sinon/pkg/sinon.js]
Jasmine.configure do |config|
  config.runner_browser = :chromeheadless
end
