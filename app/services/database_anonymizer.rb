# anonymizes historical data to use for attendance forecasting.
class DatabaseAnonymizer
  def initialize(logger = nil)
    require 'faker'

    @logger = logger || Logger.new(STDOUT)
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "#{msg}\n"
    end
  end

  def anonymize_database
    @logger.info('Anonymizing users...')
    User.find_each { |u| anonymize_user(u) }

    @logger.info('Anonymizing Meetup users...')
    MeetupUser.find_each { |u| anonymize_meetup_user(u) }

    @logger.info('Anonymizing surveys...')
    Survey.find_each { |s| anonymize_survey(s) }

    @logger.info('Anonymizing RSVPs...')
    Rsvp.find_each { |r| anonymize_rsvp(r) }

    @logger.info('Anonymizing profiles...')
    Profile.find_each { |p| anonymize_profile(p) }

    @logger.info('Anonymizing locations...')
    Location.find_each { |l| anonymize_location(l) }

    @logger.info('Anonymizing event emails...')
    EventEmail.find_each { |ee| anonymize_event_email(ee) }

    @logger.info('Removing authentications...')
    delete_records(Authentication)

    @logger.info('Done!')
  end

  def anonymize_user(user)
    return if user.email == 'admin@example.com' || user.email == 'organizer@example.com'
    user.email = "email_#{user.id}@example.com"
    user.first_name = Faker::Name.first_name
    user.last_name = Faker::Name.last_name
    user.gender = %w(male female genderqueer).sample
    user.last_sign_in_ip = '127.0.0.1'
    user.current_sign_in_ip = '127.0.0.1'
    user.password = 'password'
    user.save!
  end

  def anonymize_meetup_user(user)
    user.full_name = Faker::Name.name
    user.meetup_id = Random.rand(10_000_000)
    user.save!
  end

  def anonymize_survey(survey)
    survey.good_things = Faker::Lorem.sentence(1)
    survey.bad_things  = Faker::Lorem.sentence(1)
    survey.other_comments = Faker::Lorem.sentence(1)
    survey.save!
  end

  def anonymize_rsvp(rsvp)
    rsvp.subject_experience = Faker::Lorem.sentence(10)
    rsvp.teaching_experience = Faker::Lorem.sentence(10)
    rsvp.job_details = Faker::Hacker.say_something_smart
    rsvp.needs_childcare = '0'
    rsvp.childcare_info = nil
    rsvp.plus_one_host = nil
    rsvp.dietary_info = nil
    rsvp.save!
  end

  def anonymize_profile(profile)
    profile.other = Faker::Company.catch_phrase
    profile.github_username = "#{Faker::Hacker.noun.tr(' ', '-').downcase}#{Random.rand(10_000_000)}"
    profile.twitter_username = "#{Faker::Hacker.noun.tr(' ', '_').downcase}#{Random.rand(100)}"
    profile.bio = Faker::Company.bs
    profile.save!
  end

  def anonymize_location(location)
    location.notes = nil
    location.contact_info = nil
    location.save!
  end

  def anonymize_event_email(event_email)
    event_email.subject = Faker::Lorem.sentence(1)
    event_email.body = Faker::Lorem.sentence(3)
    event_email.save!
  end

  # Delete all records in `table`
  def delete_records(table)
    table.delete_all
  end
end
