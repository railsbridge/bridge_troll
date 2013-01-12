# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#this seeds the database with an admin user--for development only

if Rails.env.development? then
  new_user=User.new(
    :name => 'admin',
    :email => 'admin@example.com',
    :password => 'password',
    :password_confirmation => 'password',
    :first_name => 'Admin',
    :last_name => 'User',
  )
  new_user.admin = true
  if new_user.save
    puts "Finished running seeds.rb.  Check to see if the there is an admin user."
  else
    puts "Could not save an admin user. #{new_user.inspect}"
  end
else
  puts "This seeds.rb task is intended for the development environment only."
end
