desc "Populate courses (only run once)"
task :populate_courses, [:url] => :environment do |t, args|
  data = [
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
          description: [
            'You have little to no experience with the terminal or a graphical IDE',
            'You might have done a little bit with HTML or CSS, but not necessarily',
            'You\'re unfamiliar with terms like methods, arrays, lists, hashes, or dictionaries.'
          ]
        }, {
          level: 2,
          color: 'green',
          title: "Somewhat New to Programming",
          description: [
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
          description: [
            'You\'re comfortable using the terminal, but not necessarily a Power User',
            'You have a general understanding of a Rails app\'s structure, perhaps from a prior workshop or tutorial',
            'You know how to define a method in Ruby',
            'You have a decent handle on Ruby arrays and hashes',
          ]
        }, {
          level: 4,
          color: 'orange',
          title: "Other Programming Experience",
          description: [
            'You\'re proficient in another language and understand general programming concepts, like collections and scope.',
            'You\'re new to Ruby and Rails',
            'You might be familiar with version control and basic web architecture'
          ]
        }, {
          level: 5,
          color: 'purple',
          title: "Ready for the Next Challenge",
          description: [
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
          description: [
            'Perhaps has seen it before, but not written much (if any)',
            'Not sure what tags, attributes, or selectors are',
            '&lt;img&gt;, &lt;a&gt;, and &lt;p&gt; are exciting and new',
          ]
        }, {
          level: 2,
          color: 'green',
          title: "Some experience with HTML",
          description: [
            'New to CSS',
            'Perhaps has worked with a WYSIWIG editor but hasn\'t coded an HTML document from scratch',
            'Has heard of a tags or attributes before, but isn\'t sure what they are',
            'Recognizes <i>&lt;a href="http://google.com"&gt;this&lt;/a&gt;</i> but couldn\'t define what each piece means'
          ]
        }, {
          level: 3,
          color: 'gold',
          title: "Some experience with HTML & CSS",
          description: [
            'Has possibly worked with the web inspector in Chrome or Firebug in Firefox before',
            'Could possibly write a link in HTML',
            'Not totally comfortable with CSS, but gets the basics'
          ]
        }, {
          level: 4,
          color: 'orange',
          title: "Comfortable editing CSS & HTML",
          description: [
            'Knows about web development, but not a lot of front end experience',
            'Maybe knows a programming language',
            'Perhaps has used the Web Inspector before'
          ]
        }, {
          level: 5,
          color: 'purple',
          title: "Ready to make a beautiful site",
          description: [
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
      description: 'This workshop will teach programming using Javascript. You can find all the curriculum materials at <a href="http://docs.railsbridge.org">docs.railsbridge.org</a>.',
      levels: [
        {
          level: 1,
          color: 'blue',
          title: "No Programming Experience",
          description: [
            'Totally new to Javascript itself',
            'Made a webpage before, maybe at a RailsBridge Front End Workshop',
            'No experience with programming languages other than HTML and CSS',
          ]
        }, {
          level: 2,
          color: 'orange',
          title: "Programmer new to Javascript",
          description: [
            'Comfortable making a complex webpage',
            'Some experience in a programming language like ActionScript, C, Java, Ruby or Python',
            'Has seen javascript, but didn\'t really understand how it worked',
          ]
        }, {
          level: 3,
          color: 'purple',
          title: "Some experience with JavaScript",
          description: [
            'Feels comfortable writing functions and objects in JavaScript',
            'Used jQuery before and has seen an AJAX request, but doesn\'t understand all the moving parts',
            'Interested in learning how to organize JavaScript code using models and views'
          ]
        }

      ]
    }, {
      id: 4,
      name: 'iOS',
      title: 'Intro to iOS Development',
      description: 'This workshop will cover how to make an iOS application.',
      levels: [
        {
          level: 1,
          color: 'blue',
          title: "Totally New to Programming",
          description: [
            'You have little to no experience with the terminal or a graphical IDE',
            'You might have done a little bit with HTML or CSS, but not necessarily',
          ]
        }, {
          level: 2,
          color: 'green',
          title: "Somewhat New to Programming",
          description: [
            'You may have used the terminal a little — to change directories, for instance',
            'You might have done an online programming tutorial or two',
            'You know what a method is',
          ]
        }, {
          level: 3,
          color: 'gold',
          title: "Some iOS App Development Experience",
          description: [
            "You're comfortable using the terminal, but not necessarily a Power User",
            'You have a general understanding of XCode and of iOS app structure, perhaps from a prior workshop or tutorial',
            'Some programming experience in another language like Ruby, Python, C, Java',
          ]
        }, {
          level: 4,
          color: 'pink',
          title: "Experienced Designer new to iOS programming",
          description: [
            "You're proficient in design tools (Adobe Creative Suite, etc)",
            "You're familiar with general UI design principles",
            "You might be familiar with HTML and CSS.",
            "You're new to the XCode environment and to iOS app development",
          ]
        }, {
          level: 5,
          color: 'orange',
          title: "Experienced Programmer new to iOS programming",
          description: [
            "You're proficient in another language and understand general programming concepts",
            "You're new to the XCode environment and to iOS app development",
            'You might be familiar with version control',
          ]
        },
      ]
    }, {
      id: 5,
      name: 'RUBY_JS_PAIRING',
      title: 'Open Source Pairing Workshop',
      description: 'This workshop is an opportunity to improve your coding skills by pair programming on an open source project.',
      levels: [
        {
          level: 2,
          color: 'orange',
          title: "Javascript",
          description: [
            'Some experience writing JavaScript at a front-end workshop or personal project',
            'You have a basic understanding of the Browser DOM (Document Object Model)',
            'You have built a website or other app on your own',
          ]
        }, {
          level: 3,
          color: 'purple',
          title: "Ruby",
          description: [
            'Some experience writing Ruby at a prior workshop and/or personal project',
            'You have built a website or other app on your own',
          ]
        }
      ]
    }, {
      id: 6,
      name: 'Android',
      title: 'Intro to Android Development',
      description: 'This workshop will cover how to make an Android application.',
      levels: [
        {
          level: 1,
          color: 'blue',
          title: "Totally New to Programming",
          description: [
            'You have little to no experience with the command line or a graphical IDE',
            'You might have done a little bit with HTML or CSS, but not necessarily',
            'You\'re unfamiliar with terms like methods, arrays, lists, hashes, or dictionaries.'
          ]
        }, {
          level: 2,
          color: 'green',
          title: "Somewhat New to Programming",
          description: [
            'You may have used the command line a little — to change directories, for instance',
            'You might have done an online programming tutorial or two',
            'You know what a method is'
          ]
        }, {
          level: 3,
          color: 'gold',
          title: "Some Android App Development Experience",
          description: [
            'You\'re comfortable using the command line, but not necessarily a Power User',
            'You have a general understanding of an Android app\'s structure, perhaps from a prior workshop or tutorial',
            'Some programming experience in another language like Ruby, Python, C, Java'
          ]
        }, {
          level: 4,
          color: 'pink',
          title: "Experienced Non-Java Programmer new to Android app development",
          description: [
            'You\'re proficient in non-Java programming language and understand general programming concepts, like collections and scope.',
            'You\'re new to the Android Studio environment and to Android app development',
            'You might be familiar with version control'
          ]
        }, {
          level: 5,
          color: 'orange',
          title: "Experienced Java Programmer new to Android app development",
          description: [
            'You\'re proficient in Java and understand general programming concepts, like collections and scope.',
            'You\'re new to the Android Studio environment and to Android app development',
            'You might be familiar with version control'
          ]
        }
      ]
    }, {
      id: 7,
      name: 'Go',
      title: 'Go Programming Language',
      description: 'This is a Golang event. The focus will be on developing a variety of systems and applications in Go. You can find all the curriculum materials at <a href="https://github.com/gobridge/hardcore-go">https://github.com/gobridge/hardcore-go</a>.',
      levels: [
        {
          level: 1,
          color: 'blue',
          title: "Totally New to Programming",
          description: [
            'You have little to no experience with the terminal or a graphical IDE',
            'You might have done a little bit with HTML or CSS, but not necessarily',
            'You\'re unfamiliar with terms like functions, arrays, lists, hashes/maps, or dictionaries.'
          ]
        }, {
          level: 2,
          color: 'green',
          title: "Somewhat New to Programming",
          description: [
            'You may have used the terminal a little — to change directories, for instance',
            'You might have done an online programming tutorial or two',
            'You don\'t have a lot of experience with Rails',
            'You know what a function is',
            'You aren\'t totally clear on how a request gets from the browser to your app'
          ]
        }, {
          level: 3,
          color: 'gold',
          title: "Some Go Experience",
          description: [
            'You\'re comfortable using the terminal, but not necessarily a Power User',
            'You have a general understanding of a Go app\'s structure, perhaps from a prior workshop or tutorial',
            'You know how to define a function in Go',
            'You have a decent handle on Go slices and maps',
          ]
        }, {
          level: 4,
          color: 'orange',
          title: "Other Programming Experience",
          description: [
            'You\'re proficient in another language and understand general programming concepts, like collections and scope.',
            'You\'re new to Go',
            'You might be familiar with version control and basic web architecture'
          ]
        }, {
          level: 5,
          color: 'purple',
          title: "Ready for the Next Challenge",
          description: [
            'You\'ve gone through the <a href="http://tour.golang.org/welcome/1">Go Tour</a>.',
            'You\'re comfortable with the terminal',
            'You want to problem-solve instead of copying other\'s code',
            'You want to build an app with minimum guidance'
          ]
        }
      ]
    }
  ]
  data.each do |course|
    c = Course.where(id: course[:id])
    if c.empty?
      c = Course.create(id: course[:id], name: course[:name], title: course[:title], description: course[:description])
    else
      c = c.take!
    end
    course[:levels].each do |level|
      if Level.where(num: level[:level], course_id: course[:id]).empty?
        l = Level.create(num: level[:level], color: level[:color], title: level[:title], course_id: course[:id], level_description: level[:description])
        c.levels << l
      end
    end
  end
end