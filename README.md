# Bridge Troll

[![Build Status](https://secure.travis-ci.org/railsbridge/bridge_troll.png)](http://travis-ci.org/railsbridge/bridge_troll)

This is a Rails app that helps organizers of RailsBridge workshops plan their events. We're planning to add features eventually to make it easier for organizers follow up with students and volunteers.

* [The running app](http://bridgetroll.herokuapp.com/)
* [The staging server](http://bridgetroll-staging.herokuapp.com/)
* [Continuous integration on
  travis-ci.org](http://travis-ci.org/railsbridge/bridge_troll)
* [Pivotal Tracker project](https://www.pivotaltracker.com/projects/388105)

## Want to help out?

Please join the [google group](http://groups.google.com/group/railsbridge-apps)

Pick a story to work on, fork the project, and then make your changes and send a pull request.  Note: change git clone below to be *your* repo.

## Setting up for development

rvm is expected.  We're using 1.9.2 -- there's an rvmrc which should help make sure you are using the right ruby version.

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

