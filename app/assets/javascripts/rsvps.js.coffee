$ ->
  children_info_fields = $('#rsvp_childcare_info').closest('.field')
  $('#rsvp_needs_childcare').change ->
    if $('#rsvp_needs_childcare').is(':checked')
      children_info_fields.removeClass('hidden')
    else
      children_info_fields.addClass('hidden')

#popover with default options: not implemented
# list = (item) ->
#   '<li>'+item+'</li>'

# mypopover = (selector, title, content) ->
#   $(selector).popover({
#     'trigger':'hover', 
#     'html':'true',
#     'title': title,
#     'content': list item for item in content
#   })

#popover windows for Rails courses
$ ->
  $('#blue').popover({
    'trigger':'hover', 
    'html':'true',
    'title': 'Totally New to Programming',
    'content':
    	'<ul>
    		<li>You have little to no experience with the terminal or a graphical IDE</li>
            <li>You might have done a little bit with HTML or CSS, but not necessarily</li>
            <li>You\'re unfamiliar with terms like methods, arrays, lists, hashes, or dictionaries.</li>
         </ul>'
  })

$ ->
  $('#green').popover({
    'trigger':'hover',
    'html':'true',
    'title': 'Somewhat New to Programming',
    'content':
        '<ul>
           <li>You may have used the terminal a little — to change directories, for instance</li>
           <li>You might have done an online programming tutorial or two</li>
           <li>You don\'t have a lot of experience with Rails</li>
           <li>You know what a method is</li>
           <li>You are probably unfamiliar with the MVC pattern</li>
	     </ul>'
  })

$ ->
  $('#gold').popover({
    'trigger':'hover',
    'html':'true',
    'title': 'Some Rails Experience',
    'content':
        '<ul>
           <li>You\'re comfortable using the terminal, but not necessarily a Power User</li>
           <li>You have a general understanding of MVC, perhaps from a prior workshop or tutorial</li>
           <li>You know how to define a method in Ruby</li>
           <li>You have a decent handle on Ruby arrays and hashes</li>
        </ul>'
  })

$ ->
  $('#orange').popover({
    'trigger':'hover',
    'html':'true',
    'title': 'Other Programming Experience',
    'content':
        '<ul>
           <li>You\'re proficient in another language and understand general programming concepts, like collections and scope.</li>
           <li>You\'re new to Ruby and Rails</li>
           <li>You might be familiar with version control and basic web architecture</li>
        </ul>'
  })

$ ->
  $('#purple').popover({
    'trigger':'hover',
    'html':'true',
    'title': 'Ready for the Next Challenge',
    'content':
        '<ul>
           <li>You\'ve exhausted the fun of the Suggestotron/Intro Rails curriculum</li>
           <li>You\'re comfortable with the terminal</li>
           <li>You want to problem-solve instead of copying other\'s code</li>
           <li>You want to build an app without using scaffolds</li>
        </ul>'
  })

#popover windows for FrontEnd courses
$ ->
  $('#101').popover({
    'trigger':'hover', 
    'html':'true',
    'title': 'Totally new to HTML and CSS',
    'content':
    	'<ul>
           <li>Perhaps has seen it before, but not written much (if any)</li>
           <li>Not sure what tags, attributes, or selectors are</li>
           <li>&lt;img&gt;, &lt;a&gt;, and &lt;p&gt; are exciting and new</li>
         </ul>'
  })

$ ->
  $('#102').popover({
    'trigger':'hover',
    'html':'true',
    'title': 'Knows the basic idea behind HTML and has possibly written some',
    'content':
        '<ul>
           <li>New to CSS</li>
           <li>Perhaps has worked with a WYSIWIG editor but hasn\'t coded an HTML document from scratch</li>
           <li>Has heard of a tags or attributes before, but isn\'t sure what they are</li>
           <li>Recognizes &lt;a href="http://www.google.com"&gt;this&lt;/a&gt; but couldn\'t define what each piece means</li>
	     </ul>'
  })

$ ->
  $('#103').popover({
    'trigger':'hover',
    'html':'true',
    'title': 'Some experience with HTML & CSS',
    'content':
        '<ul>
           <li>Has possibly worked with the web inspector in Chrome or Firebug in Firefox before</li>
           <li>Could possibly write a link in HTML</li>
           <li>Not totally comfortable with CSS, but gets the basics</li>
        </ul>'
  })

$ ->
  $('#201').popover({
    'trigger':'hover',
    'html':'true',
    'title': 'Comfortable editing CSS & HTML, but hasn\'t built a site from scratch',
    'content':
        '<ul>
			<li>Knows about web development, but not a lot of front end experience</li>
			<li>Maybe knows a programming language</li>
			<li>Perhaps has used the Web Inspector before</li>
		</ul>'
  })

$ ->
  $('#301').popover({
    'trigger':'hover',
    'html':'true',
    'title': 'Ready to make a beautiful site',
    'content':
        '<ul>
			<li>Knows how to include a stylesheet in an HTML document</li>
			<li>Feels comfortable with terminology like tag and attribute</li>
			<li>Has made and deployed a website with custom CSS or used a framework like Bootstrap or Foundation</li>
		</ul>'
  })