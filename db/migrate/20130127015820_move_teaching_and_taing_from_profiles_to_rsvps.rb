class MoveTeachingAndTaingFromProfilesToRsvps < ActiveRecord::Migration
  COLUMNS = [:teaching, :taing]
  def up
    puts 'sorry about your datas...'
    COLUMNS.each do |column|
      remove_column :profiles, column
      add_column :rsvps, column, :boolean, :default => false, :null => false
    end
  end

  def down
    COLUMNS.each do |column|
      remove_column :rsvps, column
      add_column :profiles, column, :boolean #this is the old convention, hence no default or non nulls
    end
  end
end
