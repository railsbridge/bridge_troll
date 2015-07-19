require 'faker'

# anonymizes historical data to use for attendance forecasting.
class DatabaseAnonymizer
  def self.anonymize_database
    User.all.map { |u| anonymize_user(u) }
    MeetupUser.all.map { |u| anonymize_meetup_user(u) }
    Survey.all.map { |s| anonymize_survey(s) }
    Rsvp.all.map { |r| anonymize_rsvp(r) }
    Profile.all.map { |p| anonymize_profile(p) }
    delete_records(Authentication)
  end

  def self.anonymize_user(user)
    return if user.email == 'admin@example.com' || user.email == 'organizer@example.com'
    user.email = Faker::Internet.email
    user.first_name = Faker::Name.first_name
    user.last_name = Faker::Name.last_name
    user.gender = %w(male female genderqueer).sample
    user.encrypted_password = 'password'
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
    puts "original rsvp: #{rsvp.inspect}"
    rsvp.subject_experience = Faker::Lorem.sentence(1)
    rsvp.teaching_experience = Faker::Lorem.sentence(1)
    rsvp.job_details = Faker::Hacker.say_something_smart
    rsvp.childcare_info = Faker::Lorem.sentence(1)
    rsvp.plus_one_host = Faker::Lorem.sentence(1)
    rsvp.dietary_info = Faker::Lorem.words(2).join()
    rsvp.save
  end

  def self.anonymize_profile(profile)
    profile.user_id = Random.rand(10_000_000)
    profile.other = Faker::Company.catch_phrase
    profile.github_username = "#{Faker::Hacker.noun}#{Random.rand(10_000_000)}"
    profile.bio = Faker::Company.bs
    profile.save
  end

  # Delete all records in `table`
  def self.delete_records(table)
    table.delete_all
  end
end
