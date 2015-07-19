require 'faker'

# anonymizes historical data to use for attendance forecasting.
class DatabaseAnonymizer
  def self.anonymize_database
    status_output('Anonymizing users...')
    User.find_each { |u| anonymize_user(u) }
    status_output('Anonymizing Meetup users...')
    MeetupUser.find_each { |u| anonymize_meetup_user(u) }
    status_output('Anonymizing surveys...')
    Survey.find_each { |s| anonymize_survey(s) }
    status_output('Anonymizing RSVPs...')
    Rsvp.find_each { |r| anonymize_rsvp(r) }
    status_output('Anonymizing profiles...')
    Profile.find_each { |p| anonymize_profile(p) }
    status_output('Removing authentications...')
    delete_records(Authentication)
    status_output('Done!')
  end

  def self.anonymize_user(user)
    return if user.email == 'admin@example.com' || user.email == 'organizer@example.com'
    user.email = "#{Faker::Lorem.characters(10)}@example.com"
    user.first_name = Faker::Name.first_name
    user.last_name = Faker::Name.last_name
    user.gender = %w(male female genderqueer).sample
    user.password = 'password'
    user.save
  end

  def self.anonymize_meetup_user(user)
    user.full_name = Faker::Name.name
    user.meetup_id = Random.rand(10_000_000)
    user.save
  end

  def self.anonymize_survey(survey)
    survey.good_things = Faker::Lorem.sentence(1)
    survey.bad_things  = Faker::Lorem.sentence(1)
    survey.other_comments = Faker::Lorem.sentence(1)
    survey.save
  end

  def self.anonymize_rsvp(rsvp)
    rsvp.subject_experience = Faker::Lorem.sentence(1)
    rsvp.teaching_experience = Faker::Lorem.sentence(1)
    rsvp.job_details = Faker::Hacker.say_something_smart
    rsvp.childcare_info = Faker::Lorem.sentence(1)
    rsvp.plus_one_host = Faker::Lorem.sentence(1)
    rsvp.dietary_info = Faker::Lorem.words(2).join()
    rsvp.save
  end

  def self.anonymize_profile(profile)
    profile.other = Faker::Company.catch_phrase
    profile.github_username = "#{Faker::Hacker.noun}#{Random.rand(10_000_000)}"
    profile.bio = Faker::Company.bs
    profile.save
  end

  # Delete all records in `table`
  def self.delete_records(table)
    table.delete_all
  end


  # Print given status message
  def self.status_output(message)
    sleep(2)
    puts "#{message}"
    $stdout.flush
  end
end
