class AddFirstAndLastNameToUser < ActiveRecord::Migration
  class User < ActiveRecord::Base
  end

    #Name Parsing Assumptions
    #first_name name is always the first word in user.name
    #Suffix is at the end of a name and is properly punctuated with a period if necessary
    #Middile name or initial will be dropped
    #If a suffix is identified it will be returned with the preceding word as the last_name
    #If no suffix is identified last_name will return the last word

  def last_name(name)
    name_array = name.split
    if name_array.blank? || name_array.length == 1
      nil
    else
      name_array.last.match(/PH\.D|M\.D\.|DR\.|4th|IV|3RD|III|2ND|II|R\.N\.|JR\.|SR\.|ESQ\.?/i) ?
          name_array.last(2).join(" ") : name_array.last
    end
  end

  def up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string

    User.find_each do |user|
      user.update_attributes(:first_name => user.name.split[0], :last_name => last_name(user.name))
    end

    remove_column :users, :name
  end

  def down
    add_column    :users, :name, :string
    User.find_each do |user|
      user.update_attributes(:name => "#{user.first_name} #{user.last_name}")
    end
    remove_column :users, :first_name
    remove_column :users, :last_name
  end

end
