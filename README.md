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

```

* [The running app](http://bridgetroll.herokuapp.com/)
* [Pivotal Tracker project](https://www.pivotaltracker.com/projects/388105)

```
# setting up for development

```
git clone git@github.com:railsbridge/bridge_troll
cd bridge_troll
bundle install
rake db:create:all
rake db:migrate
rake db:seed
rails s
```
