# frozen_string_literal: true

namespace :jasmine do
  desc 'Precompile assets, run Jasmine browser specs, and clean up precompiled assets'
  task ci: :environment do
    # 1. Precompile assets for Jasmine tests
    Rake::Task['assets:precompile'].invoke

    # 2. Run Jasmine browser specs
    raise 'Jasmine browser specs failed' unless system('jasmine-browser-runner runSpecs')
  ensure
    # 3. Clean up precompiled assets
    Rake::Task['assets:clobber'].invoke
  end
end
