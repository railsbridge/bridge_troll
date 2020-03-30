# frozen_string_literal: true

module CoursePopulator
  module_function

  def populate_courses
    file = YAML.safe_load(File.expand_path('courses.yaml', __dir__))
    YAML.load_file(file).each do |course|
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
end
