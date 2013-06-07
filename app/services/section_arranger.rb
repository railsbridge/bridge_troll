class SectionArranger
  IDEAL_CLASS_SIZE = 6.0

  def self.section_size_given_total_students(count)
    if count <= IDEAL_CLASS_SIZE + 2
      return count
    end

    number_of_sections = (count / IDEAL_CLASS_SIZE).ceil
    (count / number_of_sections.to_f).ceil
  end

  def self.arrange(event)
    event.sections.destroy_all
    return if event.student_rsvps.count == 0

    section_counts = Hash[self.rsvp_counts(event).map { |level, count| [level, self.section_size_given_total_students(count)]}]
    sections = Hash.new { |hsh, key| hsh[key] = []; hsh[key] }
    event.student_rsvps.each do |rsvp|
      section = sections[rsvp.class_level].try(:last)
      unless section && section.rsvps.count < section_counts[rsvp.class_level]
        section = event.sections.create(name: "Level #{rsvp.class_level} Section")
        sections[rsvp.class_level] << section
      end
      rsvp.update_attribute(:section_id, section.id)
    end

    event.volunteer_rsvps.each do |rsvp|
      least_volunteered_section = event.sections.sort_by { |section|
        section.rsvps.where(role_id: Role::VOLUNTEER.id).length
      }.first
      rsvp.update_attribute(:section_id, least_volunteered_section.id)
    end
  end

  private

  def self.rsvp_counts(event)
    Hash[event.student_rsvps.select('class_level, count(class_level) count').group(:class_level).map { |rsvp_group|
      [rsvp_group.class_level, rsvp_group.count]
    }]
  end
end