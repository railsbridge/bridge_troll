class Course < ActiveHash::Base
  include ActiveHash::Enum
  self.data = [
    {
      id: 1,
      name: 'RAILS',
      title: 'Ruby on Rails',
      description: 'This is a Ruby on Rails event. The focus will be on developing functional web apps and programming in Ruby.  You can find all the curriculum materials at <a href="http://docs.railsbridge.org">docs.railsbridge.org</a>.',
      levels: [
        {
          level: 1,
          color: 'blue',
          title: "Totally New to Programming",
          popover_content: [
            'You have little to no experience with the terminal or a graphical IDE',
            'You might have done a little bit with HTML or CSS, but not necessarily',
            'You\'re unfamiliar with terms like methods, arrays, lists, hashes, or dictionaries.'
          ]
        }, {
          level: 2,
          color: 'green',
          title: "Somewhat New to Programming",
          popover_content: [
            'You may have used the terminal a little — to change directories, for instance',
            'You might have done an online programming tutorial or two',
            'You don\'t have a lot of experience with Rails',
            'You know what a method is',
            'You are probably unfamiliar with the MVC pattern'
          ]
        }, {
          level: 3,
          color: 'gold',
          title: "Some Rails Experience",
          popover_content: [
            'You\'re comfortable using the terminal, but not necessarily a Power User',
            'You have a general understanding of MVC, perhaps from a prior workshop or tutorial',
            'You know how to define a method in Ruby',
            'You have a decent handle on Ruby arrays and hashes',
          ]
        }, {
          level: 4,
          color: 'orange',
          title: "Other Programming Experience",
          popover_content: [
            'You\'re proficient in another language and understand general programming concepts, like collections and scope.',
            'You\'re new to Ruby and Rails',
            'You might be familiar with version control and basic web architecture'
          ]
        }, {
          level: 5,
          color: 'purple',
          title: "Ready for the Next Challenge",
          popover_content: [
            'You\'ve exhausted the fun of the Suggestotron/Intro Rails curriculum',
            'You\'re comfortable with the terminal',
            'You want to problem-solve instead of copying other\'s code',
            'You want to build an app without using scaffolds'
          ]
        }
      ]
    }, {
      id: 2,
      name: 'FRONTEND',
      title: 'Front End',
      description: 'This is a Front End workshop. The focus will be on designing web apps with HTML and CSS.  You can find all the curriculum materials at <a href="http://docs.railsbridge.org/frontend">docs.railsbridge.org/frontend</a>.',
      levels: [
        {
          level: 1,
          color: 'blue',
          title: "Totally new to HTML and CSS",
          popover_content: [
            'Perhaps has seen it before, but not written much (if any)',
            'Not sure what tags, attributes, or selectors are',
            '&lt;img&gt;, &lt;a&gt;, and &lt;p&gt; are exciting and new',
          ]
        }, {
          level: 2,
          color: 'green',
          title: "Some experience with HTML",
          popover_content: [
            'New to CSS',
            'Perhaps has worked with a WYSIWIG editor but hasn\'t coded an HTML document from scratch',
            'Has heard of a tags or attributes before, but isn\'t sure what they are',
            'Recognizes <i>&lt;a href="http://google.com"&gt;this&lt;/a&gt;</i> but couldn\'t define what each piece means'
          ]
        }, {
          level: 3,
          color: 'gold',
          title: "Some experience with HTML & CSS",
          popover_content: [
            'Has possibly worked with the web inspector in Chrome or Firebug in Firefox before',
            'Could possibly write a link in HTML',
            'Not totally comfortable with CSS, but gets the basics'
          ]
        }, {
          level: 4,
          color: 'orange',
          title: "Comfortable editing CSS & HTML",
          popover_content: [
            'Knows about web development, but not a lot of front end experience',
            'Maybe knows a programming language',
            'Perhaps has used the Web Inspector before'
          ]
        }, {
          level: 5,
          color: 'purple',
          title: "Ready to make a beautiful site",
          popover_content: [
            'Knows how to include a stylesheet in an HTML document',
            'Feels comfortable with terminology like tag and attribute',
            'Has made and deployed a website with custom CSS or used a framework like Bootstrap or Foundation'
          ]
        }
      ]
    }
  ]
  enum_accessor :name
end