system "bundle exec rake db:create:all"
system "bundle exec rake db:migrate"

sh -e /etc/init.d/xvfb start
