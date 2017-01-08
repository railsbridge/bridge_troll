class CoursePopulator
  def populate_courses
    default_course_data.each do |course|
      c = Course.where(
        id: course[:id]
      ).first_or_create!(
        name: course[:name],
        title: course[:title],
        description: course[:description]
      )
      course[:levels].each do |level|
        c.levels.where(
          num: level[:level]
        ).first_or_create!(
          color: level[:color],
          title: level[:title],
          level_description: level[:level_description]
        )
      end
    end
  end

  private

  def default_course_data
    [
      {
        id: 1,
        name: 'RAILS',
        title: 'Ruby on Rails',
        description: 'This is a Ruby on Rails event. The focus will be on developing web apps and programming in Ruby.  You can find all the curriculum materials at <a href="http://docs.railsbridge.org">docs.railsbridge.org</a>.',
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
        description: 'This workshop will teach programming using Javascript. You can find all the curriculum materials at <a href="http://docs.railsbridge.org">docs.railsbridge.org</a>.',
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
              'Some experience in a programming language like ActionScript, C, Java, Ruby or Python',
              'Has seen javascript, but didn\'t really understand how it worked',
            ]
          }, {
            level: 3,
            color: 'purple',
            title: "Some experience with JavaScript",
            level_description: [
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
            level_description: [
              'You have little to no experience with the terminal or a graphical IDE',
              'You might have done a little bit with HTML or CSS, but not necessarily',
            ]
          }, {
            level: 2,
            color: 'green',
            title: "Somewhat New to Programming",
            level_description: [
              'You may have used the terminal a little — to change directories, for instance',
              'You might have done an online programming tutorial or two',
              'You know what a method is',
            ]
          }, {
            level: 3,
            color: 'gold',
            title: "Some iOS App Development Experience",
            level_description: [
              "You're comfortable using the terminal, but not necessarily a Power User",
              'You have a general understanding of XCode and of iOS app structure, perhaps from a prior workshop or tutorial',
              'Some programming experience in another language like Ruby, Python, C, Java',
            ]
          }, {
            level: 4,
            color: 'pink',
            title: "Experienced Designer new to iOS programming",
            level_description: [
              "You're proficient in design tools (Adobe Creative Suite, etc)",
              "You're familiar with general UI design principles",
              "You might be familiar with HTML and CSS.",
              "You're new to the XCode environment and to iOS app development",
            ]
          }, {
            level: 5,
            color: 'orange',
            title: "Experienced Programmer new to iOS programming",
            level_description: [
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
            level_description: [
              'Some experience writing JavaScript at a front-end workshop or personal project',
              'You have a basic understanding of the Browser DOM (Document Object Model)',
              'You have built a website or other app on your own',
            ]
          }, {
            level: 3,
            color: 'purple',
            title: "Ruby",
            level_description: [
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
            level_description: [
              'You have little to no experience with the command line or a graphical IDE',
              'You might have done a little bit with HTML or CSS, but not necessarily',
              'You\'re unfamiliar with terms like methods, arrays, lists, hashes, or dictionaries.'
            ]
          }, {
            level: 2,
            color: 'green',
            title: "Somewhat New to Programming",
            level_description: [
              'You may have used the command line a little — to change directories, for instance',
              'You might have done an online programming tutorial or two',
              'You know what a method is'
            ]
          }, {
            level: 3,
            color: 'gold',
            title: "Some Android App Development Experience",
            level_description: [
              'You\'re comfortable using the command line, but not necessarily a Power User',
              'You have a general understanding of an Android app\'s structure, perhaps from a prior workshop or tutorial',
              'Some programming experience in another language like Ruby, Python, C, Java'
            ]
          }, {
            level: 4,
            color: 'pink',
            title: "Experienced Non-Java Programmer new to Android app development",
            level_description: [
              'You\'re proficient in non-Java programming language and understand general programming concepts, like collections and scope.',
              'You\'re new to the Android Studio environment and to Android app development',
              'You might be familiar with version control'
            ]
          }, {
            level: 5,
            color: 'orange',
            title: "Experienced Java Programmer new to Android app development",
            level_description: [
              'You\'re proficient in Java and understand general programming concepts, like collections and scope.',
              'You\'re new to the Android Studio environment and to Android app development',
              'You might be familiar with version control'
            ]
          }
        ]
      }, {
        id: 7,
        name: 'BWAG Go',
        title: 'Building Web Apps With Go',
        description: "If you are reading this then you have just started your journey from newcomer to pro. No seriously, web programming in Go is so fun and easy that you won't even notice how much information you are learning along the way!
      </p>
      This course is courtesy of <a href='https://bit.ly/codegansta-bwag'>Jeremy Saenz</a>.
      </p>
      You can find all the course content at: <a href='https://bit.ly/gobridge-bwag'>https://gobridge.gitbooks.io/building-web-apps-with-go/content/en/index.html</a>.",
        levels: [
          {
            level: 2,
            color: 'green',
            title: "Somewhat New to Programming",
            level_description: [
              'You know what a function is',
              'You might have done an online programming tutorial or two',
              'You may have used the terminal a little — to change directories, for instance'
            ]
          }, {
            level: 3,
            color: 'gold',
            title: "Some Go Experience",
            level_description: [
              'You know how to define a function in Go',
              'You have a decent handle on Go slices and maps',
              'You have a general understanding of a Go app\'s structure, perhaps from a prior workshop or tutorial',
              'You\'re comfortable using the terminal, but not necessarily a Power User'
            ]
          }, {
            level: 4,
            color: 'orange',
            title: "Other Programming Experience",
            level_description: [
              'You\'re new to Go',
              'You\'re proficient in another language and understand general programming concepts, like collections and scope.',
              'You are an intermediate-level developer',
              'You might be familiar with version control and basic web architecture'
            ]
          }
        ]
      }, {
        id: 8,
        name: 'BWAG Go Portugues',
        title: 'Building Web Apps With Go - Em Portugues',
        description: "Se você está lendo isto então você está prestes a embarcar em uma jornada de iniciante a pro. Sério! Programação web em Go é tão divertido e fácil que você nem vai perceber quanta informação você está aprendendo ao longo do curso.
      </p>
      Este curso é uma courtesia de <a href='https://bit.ly/codegansta-bwag'>Jeremy Saenz</a>.
      </p>
      Todo o material do curso está aqui: <a href='https://bit.ly/gobridge-bwag'>https://gobridge.gitbooks.io/building-web-apps-with-go/content/pt-br/index.html</a>.",
        levels: [
          {
            level: 2,
            color: 'green',
            title: "Mais ou Menos Novato(a) em Programação",
            level_description: [
              'Você sabe o que é uma função',
              'Talvez você já tenha feito um tutorial ou dois online',
              'Você sabe usar o básico do terminal - mudar de diretórios, por exemplo'
            ]
          }, {
            level: 3,
            color: 'gold',
            title: "Alguma Experiência em Go",
            level_description: [
              'Você sabe como definir uma função em Go',
              'Você entende bem como funciona slices e maps em Go',
              'Você tem um entendimento básico sobre a estrutura de um aplicativo Go, talvez de outro workshop ou tutorial',
              'Você se sente a vontade no terminal, mas não é necessariamente um Super Usuário(a)'
            ]
          }, {
            level: 4,
            color: 'orange',
            title: "Outras Experiências em Programação",
            level_description: [
              'Você não sabe Go',
              'Você é proficiente em outra linguagem e entende conceitos gerais de programação, como por exemplo coleções e escopo',
              'Você é desenvolvedor(a) de nível intermediário',
              'Talvez você saiba o básico sobre controle de versão e arquitetura web básica'
            ]
          }
        ]
      }, {
        id: 9,
        name: 'Ultimate Go',
        title: 'Ultimate Go',
        description: "This class provides an intensive, comprehensive and idiomatic view of the language. We focus on both the specification and implementation of the language, including topics ranging from language syntax, Go’s type system, concurrency, channels, testing and more. We believe this class is perfect for anyone who wants a jump start in learning Go or who wants a more thorough understanding of the language and its internals.
      </p>
      This course is courtesy of <a href='https://bit.ly/ardanlabs'>ArdanLabs</a>.
      </p>
      You can find all the course content at: <a href='https://github.com/gobridge/ultimate_go'>https://github.com/gobridge/ultimate_go</a>.",
        levels: [
          {
            level: 3,
            color: 'gold',
            title: "Some Go Experience",
            level_description: [
              'You know how to define a function in Go',
              'You have a decent handle on Go slices and maps',
              'You have a general understanding of a Go app\'s structure, perhaps from a prior workshop or tutorial',
              'You\'re comfortable using the terminal, but not necessarily a Power User'
            ]
          }, {
            level: 4,
            color: 'orange',
            title: "Other Programming Experience",
            level_description: [
              'You\'re new to Go',
              'You\'re proficient in another language and understand general programming concepts, like collections and scope.',
              'You are an intermediate-level developer',
              'You might be familiar with version control and basic web architecture'
            ]
          }
        ]
      }, {
        id: 10,
        name: "Todd McLeod's Go Course",
        title: "Learn How To Code Google's Go (golang) Programming Language",
        description: "This course consists of a series of video lectures by the University Professor in Computer Science Todd McLeod. It is a first semester university level programming course and it contains over 20 hours of content that will help you understand why the Go programming language is the best language you can learn today. It will also help you acquire additional valuable programming skills including understanding environment variables, using a command line interface (CLI) terminal, understanding SHA-1 checksums, working with GitHub, and increasing your productivity with an integrated development environment (IDE) such as Webstorm or Atom.io. This course provides options for multiple workshop sessions, each focusing on a separate set of topics.
      </p>
      Once a workshop for this course is scheduled, the teachers will be given a code to access the course for free, courtesy of
      <a href='https://bit.ly/Todd_McLeod_LHTCG'>https://twitter.com/Todd_McLeod</a>.
      </p>
      You can find all the course content at: <a href='https://bit.ly/gobridge-lhtc'>https://www.udemy.com/learn-how-to-code/</a> and at <a href='https://github.com/GoesToEleven/GolangTraining/'>https://github.com/GoesToEleven/GolangTraining/</a>.
      </p>
      Note: Please also leave Todd a review as a thank you for creating this course for everyone. This will help other students find this course.",
        levels: [
          {
            level: 1,
            color: 'blue',
            title: "Totally New to Programming",
            level_description: [
              'You have little to no experience with the terminal or a graphical IDE',
              'You might have done a little bit with HTML or CSS, but not necessarily',
              'You\'re unfamiliar with terms like functions, arrays, lists, hashes/maps, or dictionaries.',
            ]
          }, {
            level: 2,
            color: 'green',
            title: "Somewhat New to Programming",
            level_description: [
              'You know what a function is',
              'You might have done an online programming tutorial or two',
              'You may have used the terminal a little — to change directories, for instance',
            ]
          }, {
            level: 3,
            color: 'gold',
            title: "Some Go Experience",
            level_description: [
              'You know how to define a function in Go',
              'You have a decent handle on Go slices and maps',
              'You have a general understanding of a Go app\'s structure, perhaps from a prior workshop or tutorial',
              'You\'re comfortable using the terminal, but not necessarily a Power User',
            ]
          }, {
            level: 4,
            color: 'orange',
            title: "Other Programming Experience",
            level_description: [
              'You\'re new to Go',
              'You\'re proficient in another language and understand general programming concepts, like collections and scope.',
              'You are an intermediate-level developer',
              'You might be familiar with version control and basic web architecture'
            ]
          }
        ]
      }, {
        id: 11,
        name: "CLOJURE",
        title: 'Clojure',
        description: 'This is a Clojure event. The focus will be on programming in Clojure.',
        levels: [
          {
            level: 4,
            color: 'orange',
            title: 'Other Programming Experience',
            level_description: [
              'You\'re proficient in another language and understand general programming
concepts, like collections and scope.',
              'You\'re new to Clojure or functional programming',
              'You are familiar with version control and basic web architecture'
            ]
          }
        ]
      }, {
        id: 12,
        name: 'ELM',
        title: 'Elm',
        description: 'This is an Elm event. The focus will be on programming in Elm.',
        levels: [
          {
            level: 3,
            color: 'gold',
            title: "Some programming experience",
            level_description: [
              'You know how to define a function in some common programming language (Javascript, or Ruby, or Python, or similar)',
              'You have used lists or arrays in some common programming language',
              'You have used the terminal, but are not necessarily a Power User'
            ]
          },
          {
            level: 4,
            color: 'orange',
            title: 'Other programming experience, and comfortable editing CSS & HTML',
            level_description: [
              'You\'re proficient in another language and understand general programming
concepts, like collections and scope.',
              'Knows about web development, but not a lot of front end experience',
              'You\'re new to Elm or functional programming',
              'You are familiar with version control and basic web architecture'
            ]
          }
        ]
      }, {
        id: 13,
        name: "RUST",
        title: 'Rust for programmers',
        description: 'This is a Rust programming event. Some programming knowledge expected, but you don\'t yet know Rust.',
        levels: [
          {
            level: 4,
            color: 'orange',
            title: 'Other Programming Experience',
            level_description: [
              'You\'re proficient in another language and understand general programming
concepts, like collections and scope.',
              'You\'re new to Rust or functional programming',
              'You are familiar with version control and basic web architecture'
            ]
          }
        ]
      }, {
        id: 14,
        name: 'Intro to Go',
        title: 'Introduction to Go',
        description: 'This is a Go programming event. Some programming knowledge is expected, but you don\'t need to know Go.',
        levels: [
          {
            level: 2,
            color: 'green',
            title: "Somewhat New to Programming",
            level_description: [
              'You know what a function is',
              'You might have done an online programming tutorial or two',
              'You may have used the terminal a little — to change directories, for instance'
            ]
          }, {
            level: 3,
            color: 'gold',
            title: "Some Go Experience",
            level_description: [
              'You know how to define a function in Go',
              'You have a decent handle on Go slices and maps',
              'You have a general understanding of a Go app\'s structure, perhaps from a prior workshop or tutorial',
              'You\'re comfortable using the terminal, but not necessarily a Power User'
            ]
          }, {
            level: 4,
            color: 'orange',
            title: "Other Programming Experience",
            level_description: [
              'You\'re new to Go',
              'You\'re proficient in another language and understand general programming concepts, like collections and scope.',
              'You are an intermediate-level developer',
              'You might be familiar with version control and basic web architecture'
            ]
          }
        ]
      }, {
        id: 15,
        name: 'Elixir',
        title: 'Elixir and Phoenix',
        description: 'This is an ElixirBridge event. The focus will be on developing a web application using Elixir and Phoenix.',
        levels: [
          {
            level: 3,
            color: 'gold',
            title: "Some Elixir/Phoenix Experience",
            level_description: [
              'You\'re comfortable using the terminal, but not necessarily a Power User',
              'You have a general understanding of Elixir data types and the Phoenix framework structure, perhaps from a prior workshop or tutorial',
              'You know how to define a function in Elixir',
              'You have a decent handle on slices and maps'
            ]
          }, {
            level: 4,
            color: 'orange',
            title: "Other Programming Experience",
            level_description: [
              'You\'re proficient in another language and understand general programming concepts, like collections and scope.',
              'You\'re new to Elixir & Phoenix',
              'You might be familiar with version control and basic web architecture'
            ]
          }
        ]
      }, {
        id: 16,
        name: 'Learn to Code',
        title: 'Learn to Code with Ruby',
        description: 'This is an introductory event. The focus will be on learning programming fundamentals using Ruby.',
        levels: [
          {
            level: 1,
            color: 'blue',
            title: "No Programming Experience",
            level_description: [
              'You\'re brand new! You haven\'t done any programming, and that\'s OK!'
            ]
          }, {
            level: 2,
            color: 'green',
            title: "Dabbled, Maybe a Little HTML or PHP",
            level_description: [
              'You\'ve written some HTML, maybe some CSS, and maybe looked at PHP once or twice.'
            ]
          }, {
            level: 3,
            color: 'gold',
            title: "Some Programming Experience, Nothing Formal",
            level_description: [
              'Maybe you\'re a front-end developer and written a little JavaScript, or you\'ve written a WordPress plugin.'
            ]
          }, {
            level: 4,
            color: 'orange',
            title: 'I\'m a Professional Programmer',
            level_description: [
              'You should probably be volunteering instead of attending, but that\'s alright. You can come!'
            ]
          }
        ]
      }, {
        id: 17,
        name: 'Learn to Code - Go',
        title: 'Learn Code with Go',
        description: 'This is an introductory event. The focus will be on learning programming fundamentals using Go.',
        levels: [
          {
            level: 1,
            color: 'blue',
            title: "New to Programming",
            level_description: [
              'You are completely new to programming'
            ]
          },
          {
            level: 2,
            color: 'green',
            title: "Somewhat New to Programming",
            level_description: [
              'You know what a function is',
              'You might have done an online programming tutorial or two',
              'You may have used the terminal a little — to change directories, for instance'
            ]
          }, {
            level: 3,
            color: 'gold',
            title: "Some Go Experience",
            level_description: [
              'You know how to define a function in Go',
              'You have a decent handle on Go slices and maps',
              'You have a general understanding of a Go app\'s structure, perhaps from a prior workshop or tutorial',
              'You\'re comfortable using the terminal, but not necessarily a Power User'
            ]
          }, {
            level: 4,
            color: 'orange',
            title: "Other Programming Experience",
            level_description: [
              'You\'re new to Go',
              'You\'re proficient in another language and understand general programming concepts, like collections and scope.',
              'You are an intermediate-level developer',
              'You might be familiar with version control and basic web architecture'
            ]
          }
        ]
      },
    ]
  end
end
