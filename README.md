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

Then, have a look at [our Tracker project](https://www.pivotaltracker.com/projects/388105). Pick a story to work on, fork the project, and then make your changes and send a pull request.  Note: change git clone below to be *your* repo.

## Setting up for development

You'll need [rvm](http://rvm.beginrescueend.com).  We're using Ruby 1.9.2, and there's an `.rvmrc` file which should help make sure you are using the right Ruby version.

## Quickstart

```
git clone git@github.com:railsbridge/bridge_troll
cd bridge_troll
bundle install
rake db:create:all
rake db:migrate
rake db:seed
rails s
```

Note: we're using sass, so if you need to change stylesheets, you can make them automatically re-compile if you keep this running in another terminal window:

```
sass --watch public/stylesheets/sass/ public/stylesheets/
```

