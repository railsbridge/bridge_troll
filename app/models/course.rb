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
          level_description: [
            'You have little to no experience with the terminal or a graphical IDE',
            'You might have done a little bit with HTML or CSS, but not necessarily',
            'You\'re unfamiliar with terms like methods, arrays, lists, hashes, or dictionaries.'
          ]
        }, {
          level: 2,
          color: 'green',
          title: "Somewhat New to Programming",
          level_description: [
            'You may have used the terminal a little — to change directories, for instance',
            'You might have done an online programming tutorial or two',
            'You don\'t have a lot of experience with Rails',
            'You know what a method is',
            'You aren\'t totally clear on how a request gets from the browser to your app'
          ]
        }, {
          level: 3,
          color: 'gold',
          title: "Some Rails Experience",
          level_description: [
            'You\'re comfortable using the terminal, but not necessarily a Power User',
            'You have a general understanding of a Rails app\'s structure, perhaps from a prior workshop or tutorial',
            'You know how to define a method in Ruby',
            'You have a decent handle on Ruby arrays and hashes',
          ]
        }, {
          level: 4,
          color: 'orange',
          title: "Other Programming Experience",
          level_description: [
            'You\'re proficient in another language and understand general programming concepts, like collections and scope.',
            'You\'re new to Ruby and Rails',
            'You might be familiar with version control and basic web architecture'
          ]
        }, {
          level: 5,
          color: 'purple',
          title: "Ready for the Next Challenge",
          level_description: [
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
          level_description: [
            'Perhaps has seen it before, but not written much (if any)',
            'Not sure what tags, attributes, or selectors are',
            '&lt;img&gt;, &lt;a&gt;, and &lt;p&gt; are exciting and new',
          ]
        }, {
          level: 2,
          color: 'green',
          title: "Some experience with HTML",
          level_description: [
            'New to CSS',
            'Perhaps has worked with a WYSIWIG editor but hasn\'t coded an HTML document from scratch',
            'Has heard of a tags or attributes before, but isn\'t sure what they are',
            'Recognizes <i>&lt;a href="http://google.com"&gt;this&lt;/a&gt;</i> but couldn\'t define what each piece means'
          ]
        }, {
          level: 3,
          color: 'gold',
          title: "Some experience with HTML & CSS",
          level_description: [
            'Has possibly worked with the web inspector in Chrome or Firebug in Firefox before',
            'Could possibly write a link in HTML',
            'Not totally comfortable with CSS, but gets the basics'
          ]
        }, {
          level: 4,
          color: 'orange',
          title: "Comfortable editing CSS & HTML",
          level_description: [
            'Knows about web development, but not a lot of front end experience',
            'Maybe knows a programming language',
            'Perhaps has used the Web Inspector before'
          ]
        }, {
          level: 5,
          color: 'purple',
          title: "Ready to make a beautiful site",
          level_description: [
            'Knows how to include a stylesheet in an HTML document',
            'Feels comfortable with terminology like tag and attribute',
            'Has made and deployed a website with custom CSS or used a framework like Bootstrap or Foundation'
          ]
        }
      ]
    }, {
      id: 3,
      name: 'JAVASCRIPT',
      title: 'Intro to Javascript',
      description: 'This workshop will teach programming using Javascript.'\
                   'You can find all the curriculum materials at <a'\
                   'href="http://snake-tutorial.zeespencer.com.s3-website-us'\
                   '-west-2.amazonaws.com/lesson-1/">the temporary location'\
                   '</a>.',
      levels: [
        {
          level: 1,
          color: 'blue',
          title: "No Programming Experience",
          level_description: [
            'Totally new to Javascript itself',
            'Made a webpage before, maybe at a RailsBridge Front End Workshop',
            'No experience with programming languages other than HTML and CSS',
          ]
        }, {
          level: 2,
          color: 'orange',
          title: "Programmer new to Javascript",
          level_description: [
            'Comfortable making a complex webpage',
            'Some experience in a programming lanugage like ActionScript, C, Java, Ruby or Python',
            'Has seen javascript, but didn\'t really understand how it worked',
          ]
        }
      ]
    }, {
      id: 4,
      name: 'iOS',
      title: 'Intro to iOS Development',
      description: 'This workshop will cover how to make an iOS application.'\
                   'You can find temporary curriculum outline at <a'\
                   'href="https://github.com/thecodepath/ios_guides/wiki/'\
                   'iOS-1-day-Weekend-Workshop"</a>.',
      levels: [
        {
          level: 1,
          color: 'blue',
          title: "No Programming Experience",
          level_description: [
            'Totally new to all programming, including iOS',
            'Made a webpage before, maybe at a RailsBridge Front End Workshop',
            'No experience with programming languages other than HTML and CSS',
          ]
        }, {
          level: 2,
          color: 'orange',
          title: "New programmer, and new to iOS programming",
          level_description: [
            'Some programming experiencein another language like Ruby, Python, C, Java',
            'Has perhaps seen Objective-C, but didn\'t really understand how it worked',
          ]
        }, {
          level: 3,
          color: 'purple',
          title: "Experienced Programmer new to iOS programming",
          level_description: [
            'Very comfortable in programming lanugages other than Objective-C.',
            'Experienced programmer, but new to creating iOS apps',
          ]
        },
      ]
    }
  ]
  enum_accessor :name
end
