class SectionArranger
  IDEAL_CLASS_SIZE = 6.0

  def self.section_size_given_total_students(count)
    if count <= IDEAL_CLASS_SIZE + 2
      return count
    end

    number_of_sections = (count / IDEAL_CLASS_SIZE).round
    (count / number_of_sections.to_f).ceil
  end

  def self.arrange(event, checked_in = 'indiscriminate')
    event.sections.destroy_all
    return if event.student_rsvps.count == 0

    if checked_in == 'any'
      student_rsvps = event.student_rsvps.where("checkins_count > 0")
      volunteer_rsvps = event.volunteer_rsvps.where("checkins_count > 0")
    elsif checked_in == 'indiscriminate'
      student_rsvps = event.student_rsvps
      volunteer_rsvps = event.volunteer_rsvps
    else
      session_id = checked_in.to_i
      student_rsvps = event.student_rsvps.
        joins(:rsvp_sessions).
        where('rsvp_sessions.event_session_id' => session_id).
        where("rsvp_sessions.checked_in = ?", true).readonly(false)
      volunteer_rsvps = event.volunteer_rsvps.
        joins(:rsvp_sessions).
        where('rsvp_sessions.event_session_id' => session_id).
        where("rsvp_sessions.checked_in = ?", true).readonly(false)
    end

    section_counts = Hash[self.rsvp_counts(event).map { |level, count| [level, self.section_size_given_total_students(count)]}]
    sections = Hash.new { |hsh, key| hsh[key] = []; hsh[key] }

    student_rsvps.each do |rsvp|
      section = sections[rsvp.class_level].try(:last)
      unless section && section.rsvps.count < section_counts[rsvp.class_level]
        section = event.sections.create(name: "Level #{rsvp.class_level} Section", class_level: rsvp.class_level)
        sections[rsvp.class_level] << section
      end
      rsvp.update_attribute(:section_id, section.id)
    end

    # Put potential teachers in the front of the list
    sorted_volunteer_rsvps = volunteer_rsvps.sort do |a, b|
      if a.teaching? == b.teaching?
        a.id <=> b.id
      elsif a.teaching?
        -1
      elsif b.teaching?
        1
      end
    end

    # Remove volunteers that don't want to teach or ta
    sorted_volunteer_rsvps = sorted_volunteer_rsvps.find_all do |rsvp|
      rsvp.teaching? || rsvp.taing?
    end

    # Distribute volunteers to the smallest class until there are none left
    sorted_volunteer_rsvps.each do |rsvp|
      least_volunteered_section = event.sections.sort_by { |section|
        section.rsvps.where(role_id: Role::VOLUNTEER.id).length
      }.first
      rsvp.update_attribute(:section_id, least_volunteered_section.id)
    end
  end

  private

  def self.rsvp_counts(event)
    Hash[event.student_rsvps.select('class_level, count(class_level) count').group(:class_level).map { |rsvp_group|
      [rsvp_group.class_level, rsvp_group.count.to_i]
    }]
  end
end