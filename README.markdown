# Bridge Troll

 
[![Build Status](https://secure.travis-ci.org/railsbridge/bridge_troll.png)](http://travis-ci.org/railsbridge/bridge_troll)
 

This is a Rails app that helps RailsBridge workshop organizers plan their events. We also use it as a teaching tool and an open-source community testbed. 
 

The feature set is currently pretty minimal - definitely *pre-alpha*. Eventually, we'd like to fill out the organizer feature set, initially for volunteers to sign up and help organizers know who is coming and what they can do, later to incorporate ways for organizers follow up with students and volunteers.
 

* [The running app](http://bridgetroll.herokuapp.com/)
* [The staging server](http://bridgetroll-staging.herokuapp.com/)
* [Continuous integration on travis-ci.org](http://travis-ci.org/railsbridge/bridge_troll)
* [Bugs](http://github.com/railsbridge/bridge_troll/issues)
 

## Want to help out?

 
Please join the [google group](https://groups.google.com/forum/?fromgroups#!forum/bridge-troll) and send a quick note introducing yourself.
 

Then, have a look at our [feature backlog](https://www.pivotaltracker.com/projects/608983). Pick an issue to work on, fork the project, and then make your changes and send a pull request.
 

## Setting up for development


You'll need [rvm](http://rvm.beginrescueend.com).  We're using Ruby 1.9.2 and Rails 3.1, and there's an `.rvmrc` file which should help make sure you are using the right Ruby version.


## Quickstart

Note: change `git clone` below to be *your* repo.

```
git clone git@github.com:yourname/bridge_troll
cd bridge_troll
script/bootstrap
rails s
```

Go to http://localhost:3000/ and you can play with the app.

## Running tests

You will need to install phantomjs for tests to run successfully. On OSX with Homebrew, try
```
brew update
brew install phantomjs
```

Then you can run tests by doing
```
script/test
```

