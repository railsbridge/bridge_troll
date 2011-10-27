require 'ruby-debug'

module MigrationHelper 
  def copy_attributes(keys, source, target)
    keys.each do |key|
      target[key] = source[key]
    end
    target.save
  end    
end