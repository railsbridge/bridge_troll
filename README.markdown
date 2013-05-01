# Bridge Troll
 
[![Build Status](https://secure.travis-ci.org/railsbridge/bridge_troll.png)](http://travis-ci.org/railsbridge/bridge_troll)


Bridge Troll is a Rails app that helps RailsBridge workshop organizers plan their events. Right now it allows organizers to create events and volunteers to RSVP to them. Next step is adding student RSVPs and class sorting logic. We have something of a roadmap [here](https://github.com/railsbridge/bridge_troll/wiki/Roadmap).

New? Keep reading this, and then head to the wiki to read the [contributor guidelines](https://github.com/railsbridge/bridge_troll/wiki/Contributor-Guidelines).

## Features & Bugs
* New features are in our [Pivotal Tracker project](https://www.pivotaltracker.com/projects/608983).
* Bugs are in [GitHub Issues](https://github.com/railsbridge/bridge_troll/issues?state=open).

## The App
* The real live production application lives at [bridgetroll.herokuapp.com](http://bridgetroll.herokuapp.com/)
* The staging server lives at [bridgetroll-staging.herokuapp.com](http://bridgetroll-staging.herokuapp.com/)
* The continuous integration server is at [travis-ci.org/railsbridge/bridge_troll](http://travis-ci.org/railsbridge/bridge_troll)

## Want to help out?
Join the [google group](https://groups.google.com/forum/?fromgroups#!forum/bridge-troll) and send a quick note introducing yourself.

Then, have a look at our [feature backlog](https://www.pivotaltracker.com/projects/608983). Pick a feature to work on, fork the project, code some code, and send a [really good pull request](http://railsbridge.github.com/bridge_troll/). Not sure what to do? Ask the [google group](https://groups.google.com/forum/?fromgroups#!forum/bridge-troll) for advice!


## Setting up for development

You'll need a version manager for Ruby.  We recommend [rvm](http://rvm.beginrescueend.com), but [rbenv](https://github.com/sstephenson/rbenv) will work.

## Quickstart

Note: change `git clone` below to be *your* repo.

```
git clone git@github.com:yourname/bridge_troll
cd bridge_troll
script/bootstrap
rails s
```

Go to http://localhost:3000/ and you can play with the app. (Pro-tip: to create a valid user without setting up email, run User.last.confirm! in the Rails console after signing up.)

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

## Email

To receive/develop emails locally, install the MailCatcher gem (http://mailcatcher.me/). The process is as follows:

* `gem install mailcatcher` -- installs MailCatcher in your current gemset
* `mailcatcher` -- start the MailCatcher server if it isn't running already
* Visit http://localhost:1080/ in your web browser. This is your MailCatcher mailbox, where mails will appear.
* Do something in your local Bridge Troll app that would send a mail, like signing up for a new account.
* You should see the mail that Rails sent in the MailCatcher window. Woo!

Note that MailCatcher just makes it easy to see the HTML output of your mails: it doesn't guarantee that the way the mail looks like in MailCatcher is how it will look in Gmail or Outlook. Beware!

## Contributors
Literally one billion thanks to our [super awesome contributors](https://github.com/railsbridge/bridge_troll/contributors).
