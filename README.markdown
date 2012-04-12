# Bridge Troll

 
[![Build Status](https://secure.travis-ci.org/railsbridge/bridge_troll.png)](http://travis-ci.org/railsbridge/bridge_troll)
 

This is a Rails app that helps RailsBridge workshop organizers plan their events. We also use it as a teaching tool and an open-source community testbed. 
 

The feature set is currently pretty minimal - definitely *pre-alpha*. Eventually, we'd like to fill out the organizer feature set, initially for volunteers to sign up and help organizers know who is coming and what they can do, later to incorporate ways for organizers follow up with students and volunteers.
 

* [The running app](http://bridgetroll.herokuapp.com/)
* [The staging server](http://bridgetroll-staging.herokuapp.com/)
* [Continuous integration on travis-ci.org](http://travis-ci.org/railsbridge/bridge_troll)
* [Issues](/railsbridge/bridge_troll/issues)
 

## Want to help out?

 
Please join the [google group](http://groups.google.com/group/railsbridge-apps) and send a quick note introducing yourself.
 

Then, have a look at our [issues](/railsbridge/bridge_troll/issues). Pick an issue to work on, fork the project, and then make your changes and send a pull request.  Note: change git clone below to be *your* repo.
 

## Setting up for development


You'll need [rvm](http://rvm.beginrescueend.com).  We're using Ruby 1.9.2 and Rails 3.1, and there's an `.rvmrc` file which should help make sure you are using the right Ruby version.


## Quickstart


Fork the repository

```
git clone git@github.com:yourname/bridge_troll
cd bridge_troll
bundle install
# if you get an error and don't have a bundler installed run: gem install bundler
rake db:create:all
rake db:migrate
rails s
```

Go to http://localhost:3000/ and you can play with the app.

=======
OMG RAILS IS SO AWESOME



