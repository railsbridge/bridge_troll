# Bridge Troll
 
[![Build Status](https://travis-ci.org/railsbridge/bridge_troll.svg?branch=master)](http://travis-ci.org/railsbridge/bridge_troll)

Bridge Troll is a Rails app that helps workshop organizers plan their events.

Bridge Troll aims to provide a single site for students and volunteers to RSVP for workshops, so that organizers have as much information as possible in one place to help them plan their workshop. Organizers can easily contact attendees before a workshop, sort students and volunteers into classes on the workshop day, and provide follow-up surveys afterward.

Prospective organizers and attendees can sign up right now at [www.bridgetroll.org](http://www.bridgetroll.org). If you would really like roll your own, Bridge Troll is open source and you are free to fork, hack to your heart's content and deploy it to your favorite server or PaaS.

# Contributing

New? Keep reading this, and then read the [contributor guidelines](CONTRIBUTING.md).

### Where is it?
* The real live production application lives at [bridgetroll.herokuapp.com](http://bridgetroll.herokuapp.com/) or [www.bridgetroll.org](http://www.bridgetroll.org/)
* The staging server lives at [bridgetroll-staging.herokuapp.com](http://bridgetroll-staging.herokuapp.com/)
* The continuous integration server is at [travis-ci.org/railsbridge/bridge_troll](http://travis-ci.org/railsbridge/bridge_troll)

### Features & Bugs
* We use [GitHub Issues](https://github.com/railsbridge/bridge_troll/issues?state=open) for tracking bugs and features.
 * Issues marked as [Ready for Action](https://github.com/railsbridge/bridge_troll/labels/Ready%20for%20Action) are ready to go, so pick one up!
 * Bugs are, naturally, [marked as bugs](https://github.com/railsbridge/bridge_troll/labels/bug).
 * Issues marked with the [Discussion label](https://github.com/railsbridge/bridge_troll/labels/Discussion) are currently being refined. If you're interested in working on one, comment and ask what needs to be finalized before it's ready to be worked on.
 * We also mark issues as [beginner friendly](https://github.com/railsbridge/bridge_troll/labels/Beginner%20Friendly), so if you're new to Rails, check those out.

### Want to help out?
Join the [google group](https://groups.google.com/forum/?fromgroups#!forum/bridge-troll) and send a quick note introducing yourself.

Then, have a look at our [GitHub Issues](https://github.com/railsbridge/bridge_troll/issues?state=open). Pick a feature to work on, fork the project, code some code, and send a [really good pull request](http://railsbridge.github.com/bridge_troll/). Not sure what to do? Ask the [google group](https://groups.google.com/forum/?fromgroups#!forum/bridge-troll) for advice!

Curious about the longer-term? We have something of a roadmap [here](https://github.com/railsbridge/bridge_troll/wiki/Roadmap).

## Setting up for your local development environment

You'll need a version manager for Ruby.  A version manager is a command-line tool which allows you to easily install, manage, and work with multiple ruby environments. We recommend [rvm](http://rvm.io), but [rbenv](https://github.com/sstephenson/rbenv) will work.

### Quickstart

We're using a fork & pull model (see [Fork A Repo](https://help.github.com/articles/fork-a-repo) for an example), so fork this repo then clone the *forked* repo.
(Note: change *username* below to be *your* repo.)
```
git clone https://github.com/username/bridge_troll.git
cd bridge_troll
```

Make sure you have the correct version of ruby before installing the gems for this repo. If you are using rvm, run: `rvm install 2.3.1`. For rbenv, run: `rbenv install 2.3.1`.

Finish setting up your environment
```
bin/setup
```

To verify your environment is set up correctly, run the server
```
rails s
```

Go to http://localhost:3000/ and verify your success! You can play with the app locally to become more familiar with it. (Pro-tip: to create a valid user without setting up email, run User.last.confirm! in the Rails console after signing up.)

### Running tests

This project has many tests that you should run before submitting a pull request, even if it's just a simple text change. You will need to install PhantomJS to run the tests. On OSX with Homebrew, try
```
brew update
brew install phantomjs
```

If you are on a Ubuntu-based linux distribution, you can try
```
sudo apt-get install phantomjs
```

Then you can run tests by doing
```
bundle exec rake
```

### Seed Data

Seed data refers to the initial data provided with the site for training, testing, or as template for the data that you enter.

`rake db:seed` will create a sample event (called 'Seeded Test Event'), organized by a sample user, with many more sample user volunteers and students.

All the created users have easyish-to-remember logins, so a great way to test out organizer functionality is to load the seeds and log in as `organizer@example.com` with the password `password`.

Doing `rake db:seed` again will destroy all those sample persons and create the event again. The exact details of what is created can be found in `seed_event.rb`.

#### Anonymizing Data
You can replace sensitive personal information about events and participants from the data with a Rake task. Note that it will not run if your Rails environment is set to `production`.
````
rake db:anonymize
````

Restore the original data to your database with
````
rake db:restore
````


### Styling Guidelines
We have created a living style guide to keep track of HTML components and their styling across the site. See it at http://localhost:3000/style_guide.

We're still working on adding every element to the page, so if you see missing components, add it to the erb template ([style_guide.html.erb](app/views/static_pages/style_guide.html.erb))

##Additional Services

The following setup is only required if you are developing for these specific features.

### Email

You don't have to set up email locally in order to develop. Note that the text of the email will appear in the log (which appears in your terminal, after you type `rails s`).

You can see rendered versions of all emails the application can send at http://localhost:3000/rails/mailers.

#### Mailcatcher

  To receive/develop emails locally, install the MailCatcher gem at http://mailcatcher.me. The process is as follows:

  1. `gem install mailcatcher` -- installs MailCatcher in your current gemset
  1. `mailcatcher` -- start the MailCatcher server if it isn't running already
  1. Visit http://localhost:1080/ in your web browser. This is your MailCatcher mailbox, where mails will appear.
  1. Do something in your local Bridge Troll app that would send a mail, like signing up for a new account.
  1. You should see the mail that Rails sent in the MailCatcher window. Woo!

  Note that MailCatcher just makes it easy to see the HTML output of your mails: it doesn't guarantee that the way the mail looks like in MailCatcher is how it will look in Gmail or Outlook. Beware!

### Working with external services

If you are just getting started, skip these steps for now.

When developing the parts of Bridge Troll that communicate with external services such as meetup and authentication, you will need to use API keys, which are most easily managed with environment variables. Environment variables control various aspects of how your code runs. 

To set up environment variables for the Rails server, you'll need to create an `.env` file in the Bridge Troll directory. Here's a sample one (note these are not real API keys):

```
MEETUP_OAUTH_KEY=90210
MEETUP_OAUTH_SECRET=5551212
RAILS_ENV=development
RACK_ENV=development
PORT=3000
```

With the `.env` file in place, the environment variables will be set every time you start the server with `rails s`.

### External Authentication

Bridge Troll uses [Omniauth](https://github.com/intridea/omniauth) to allow external authentication to a number of services.

* Twitter through [omniauth-twitter](https://github.com/arunagw/omniauth-twitter) - [set up a consumer here](https://apps.twitter.com/)
* Facebook through [omniauth-facebook](https://github.com/mkdynamic/omniauth-facebook) - [set up a consumer here](https://developers.facebook.com/apps/)
* GitHub through [omniauth-github](https://github.com/intridea/omniauth-github) - [set up a consumer here](https://github.com/settings/applications)
* Meetup through [omniauth-meetup](https://github.com/tapster/omniauth-meetup) - [set up a consumer here](http://www.meetup.com/meetup_api/oauth_consumers/)

To set up external authentication, create an oauth consumer on the site you want to authenticate with, then add [PROVIDER]_OAUTH_KEY and [PROVIDER]_OAUTH_SECRET value to the app environment.

When developing locally, it is often helpful to set up **local.bridgetroll.org** to point at your localhost server via your [hosts file](https://en.wikipedia.org/wiki/Hosts_%28file%29). You can then tell the OAuth provider to use the url local.bridgetroll.org. Often, a separate OAuth consumer needs to be set up for each environment (localhost/staging/production), but some providers (like Facebook) allow a consumer set up as "www.bridgetroll.org" to function for any subdomain (like "local.bridgetroll.org").

#### OAuth Example

To test authenticating with Meetup using your localhost server, you need to [register a new OAuth Consumer at Meetup](http://www.meetup.com/meetup_api/oauth_consumers/).

When you add a new OAuth consumer, set the _Website_ as `http://www.bridgetroll.org`, the _Redirect URI_ as `http://localhost:3000/users/auth/meetup/callback`.

The values for _key_ and _secret_ on the OAuth consumers page should be added to your local environment as MEETUP_OAUTH_KEY and MEETUP_OAUTH_SECRET, respectively.

## Contributors
One billion thanks to our [super awesome contributors](https://github.com/railsbridge/bridge_troll/contributors).

## License
The code is licensed under an [MIT license](https://github.com/railsbridge/bridge_troll/blob/master/LICENSE.md). Copyright (c) 2016 by RailsBridge.
