class SectionArranger
  IDEAL_CLASS_SIZE = 6.0

  attr_reader :event

  def initialize(event)
    @event = event
  end

  def arrange(checked_in = 'indiscriminate')
    event.sections.destroy_all
    return if event.student_rsvps_count == 0

    student_rsvps, volunteer_rsvps = rsvps_to_arrange(checked_in)

    sections = Hash.new { |hsh, key| hsh[key] = [] }

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

  def rsvps_to_arrange(checked_in)
    if checked_in == 'any'
      condition = proc { |relation| relation.where("checkins_count > 0") }
    elsif checked_in == 'indiscriminate'
      condition = proc { |relation| relation }
    else
      session_id = checked_in.to_i
      condition = proc do |relation|
        relation.
          joins(:rsvp_sessions).
          where('rsvp_sessions.event_session_id' => session_id).
          where("rsvp_sessions.checked_in = ?", true).readonly(false)
      end
    end

    [event.student_rsvps, event.volunteer_rsvps].map(&condition)
  end

  def section_size_given_total_students(count)
    if count <= IDEAL_CLASS_SIZE + 2
      return count
    end

    number_of_sections = (count / IDEAL_CLASS_SIZE).round
    (count / number_of_sections.to_f).ceil
  end

  def section_counts
    @section_counts ||= event.student_rsvps.select('event_id, class_level, count(class_level) count')
      .group(:event_id, :class_level)
      .each_with_object({}) do |rsvp_group, hsh|
      hsh[rsvp_group.class_level] = section_size_given_total_students(rsvp_group.count.to_i)
    end
  end
end