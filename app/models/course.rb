class Course < ActiveHash::Base
  include ActiveHash::Enum
  self.data = [
    {id: 1, 
    	name: 'RAILS', 
    	title: 'Ruby on Rails', 
    	description: 'This is a Ruby on Rails event. The focus will be on developing functional web apps and programming in Ruby.  You can find all the curriculum materials at <a href="http://docs.railsbridge.org">docs.railsbridge.org</a>'},
    {id: 2, 
    	name: 'FRONTEND', 
    	title: 'Front End', 
    	description: 'This is a Front End workshop. The focus will be on designing web apps with HTML and CSS.  You can find all the curriculum materials at <a href="http://docs.railsbridge.org/frontend">docs.railsbridge.org/frontend</a>'}
  ]
  enum_accessor :name
end