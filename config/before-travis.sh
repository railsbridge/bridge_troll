sudo ci/install_phantomjs
export PATH=phantomjs/bin:$PATH
phantomjs --version
bundle exec rake db:create:all
bundle exec rake db:migrate
