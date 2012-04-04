# Bridge Troll
 
[![Build Status](https://secure.travis-ci.org/railsbridge/bridge_troll.png)](http://travis-ci.org/railsbridge/bridge_troll)
 
This is a Rails app that helps RailsBridge workshop organizers plan their events. We also use it as a teaching tool and an open-source community testbed. 
 
The feature set is currently pretty minimal - definitely *pre-alpha*. Eventually, we'd like to fill out the organizer feature set, as well as incorporate ways for organizers follow up with students and volunteers.
 
* [The running app](http://bridgetroll.herokuapp.com/)
* [The staging server](http://bridgetroll-staging.herokuapp.com/)
* [Continuous integration on
  travis-ci.org](http://travis-ci.org/railsbridge/bridge_troll)
* [Pivotal Tracker project](https://www.pivotaltracker.com/projects/388105)
 
## Want to help out?
 
Please join the [google group](http://groups.google.com/group/railsbridge-apps) and send a quick note introducing yourself.
 
Then, have a look at [our Tracker project](https://www.pivotaltracker.com/projects/388105). Pick a story to work on, fork the project, and then make your changes and send a pull request.  Note: change git clone below to be *your* repo.
 
## Setting up for development
 
You'll need [rvm](http://rvm.beginrescueend.com).  We're using Ruby 1.9.2, and there's an `.rvmrc` file which should help make sure you are using the right Ruby version.
 
## Quickstart

Fork the repository
 
```
git clone git@github.com:yourname/bridge_troll
cd bridge_troll
bundle install
rake db:create:all
rake db:migrate
rails s
```



=======
OMG RAILS IS SO AWESOME

== Up and running
This app is done with ruby 1.9.2 and rails 3.1.

Assumptions
You have rvm installed; if not, you should check out http://beginrescueend.com/rvm/install/

First you need to get the code, install gems and create database:
$ git clone https://github.com/ultrasaurus/bridgetroll.git
$ cd bridgetroll
$ bundle install
# if you get an error and don't have a bundler installed run $gem install bundler
$ rake db:migrate
$ rails server

Go to http://localhost:3000/ and you can play with the app.

== Steps done on 1/17/12:

$ rails new bridgetroll -T
$ cd bridgetroll/
$ git init
$ git add .
$ git status
$ git commit -m "brand new rails app"

add this to the Gemfile
  gem 'devise'
  

$ bundle

$ rails g scaffold event title:string
$ rake db:migrate

$ rails generate devise:install
      create  config/initializers/devise.rb
      create  config/locales/devise.en.yml

Setup you must do manually if you haven't yet:

  1. In config/environments/development.rb development environment:

       config.action_mailer.default_url_options = { :host => 'localhost:3000' }

     This is a required Rails configuration. In production it must be the
     actual host of your application

  2. Ensure you have defined root_url to *something* in your config/routes.rb.
     For example:

       root :to => "events#index"

  3. Ensure you have flash messages in app/views/layouts/application.html.erb.
     For example:

       <p class="notice"><%= notice %></p>
       <p class="alert"><%= alert %></p>



$ rails g devise:install

add this to config/environments/development.rb
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
    
add this to config/routes.rb
  root :to => "events#index"
    
$ git rm public/index.html

add this to app/views/layouts/application.html.erb (under the yield)
  <p class="notice"><%= notice %></p>
  <p class="alert"><%= alert %></p>

add this to config/application.rb
  config.assets.initialize_on_precompile = false
      
$ rails generate devise User

uncomment out some of the features that you want in the user model (app/models/user.rb) and the migration file (in my case db/migrate/20120118045557_devise_create_users.rb )
see http://blazingcloud.net/2011/01/08/devise-authentication-in-rails-3/

$ rake db:migrate

$ rails generate devise:views

