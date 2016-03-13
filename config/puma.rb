worker_count = Integer(ENV['WEB_CONCURRENCY'] || 2)
workers worker_count
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

unless worker_count == 1
  preload_app!
end

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

unless worker_count == 1
  on_worker_boot do
    # Worker specific setup for Rails 4.1+
    # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
    ActiveRecord::Base.establish_connection
  end
end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
