bundle exec rake db:create:all
# ensure that migrations can run successfully
bundle exec rake db:migrate
# re-load from schema to ensure DB is empty
bundle exec rake db:reset
