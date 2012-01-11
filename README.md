```
                   ___            __               __
               __ /\_ \          /\ \             /\ \  __
 _ __    __   /\_\\//\ \     ____\ \ \____  _ __  \_\ \/\_\     __      __
/\`'__\/'__`\ \/\ \ \ \ \   /',__\\ \ '__`\/\`'__\/'_` \/\ \  /'_ `\  /'__`\
\ \ \//\ \L\.\_\ \ \ \_\ \_/\__, `\\ \ \L\ \ \ \//\ \L\ \ \ \/\ \L\ \/\  __/
 \ \_\\ \__/.\_\\ \_\/\____\/\____/ \ \_,__/\ \_\\ \___,_\ \_\ \____ \ \____\
  \/_/ \/__/\/_/ \/_/\/____/\/___/   \/___/  \/_/ \/__,_ /\/_/\/___L\ \/____/
                                                                /\____/
                                                                \_/__/

```
# What is this?

This repository has source code for an application which is designed to help RailsBridge organizers with knowing how is available to help with a workshop and who the students are, and in the future also help organizers follow-up with students and volunteers.

* [The running app](http://bridgetroll.herokuapp.com/)
* [The staging server](http://bridgetroll-staging.herokuapp.com/)
* [Pivotal Tracker project](https://www.pivotaltracker.com/projects/388105)

# Volunteer Contributors

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

