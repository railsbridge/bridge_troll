class AddCourseToEvents < ActiveRecord::Migration
  def change
    add_column :events, :course, :string
  end
end
