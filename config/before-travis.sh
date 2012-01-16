sudo aptitude --quiet=2 --without-recommends --assume-yes install firefox
bundle exec rake db:migrate
sh -e /etc/init.d/xvfb start
