require 'rails_helper'

describe DatabaseAnonymizer do
  RSpec::Matchers.define :scrub_fields do |record, fields|
    match do |actual|
      original_attributes = record.attributes.slice(*fields.map(&:to_s))
      unless original_attributes.present?
        raise "Could not determine original attributes"
      end

      actual.call

      processed_attributes = record.attributes.slice(*fields.map(&:to_s))

      @unscrubbed_attributes = []
      original_attributes.each do |key, value|
        if processed_attributes[key] == value
          @unscrubbed_attributes << key
        end
      end

      @unscrubbed_attributes.length == 0
    end

    failure_message do |actual|
      <<~EOT
        Did not seem to scrub these #{record.class} attributes:
        #{@unscrubbed_attributes.join(', ')}
      EOT
    end

    def supports_block_expectations?
      true
    end
  end

  describe '#anonymize_database' do
    let(:logger) { Logger.new(STDOUT) }
    let(:anonymizer) { DatabaseAnonymizer.new(logger) }
    let(:anonymize) { anonymizer.anonymize_database }

    before do
      logger.level = Logger::WARN
    end

    it 'anonymizes the User table' do
      create_list(:user, 2)
      expect(anonymizer).to receive(:anonymize_user).exactly(User.count).times
      anonymize
    end

    it 'anonymizes the Survey table' do
      create_list(:survey, 2)
      expect(anonymizer).to receive(:anonymize_survey).exactly(Survey.count).times
      anonymize
    end

    it 'anonymizes the RSVP table' do
      create_list(:rsvp, 2)
      expect(anonymizer).to receive(:anonymize_rsvp).exactly(Rsvp.count).times
      anonymize
    end

    it 'anonymizes the Profile table' do
      create_list(:user, 2)
      expect(anonymizer).to receive(:anonymize_profile).exactly(Profile.count).times
      anonymize
    end

    it 'anonymizes the MeetupUser table' do
      create_list(:meetup_user, 2)
      expect(anonymizer).to receive(:anonymize_meetup_user).exactly(MeetupUser.count).times
      anonymize
    end

    it 'anonymizes the Location table' do
      create_list(:location, 2)
      expect(anonymizer).to receive(:anonymize_location).exactly(Location.count).times
      anonymize
    end

    it 'anonymizes the EventEmail table' do
      create_list(:event_email, 2)
      expect(anonymizer).to receive(:anonymize_event_email).exactly(EventEmail.count).times
      anonymize
    end

    it 'deletes the Authentication table' do
      expect(anonymizer).to receive(:delete_records).with(Authentication)
      anonymize
    end
  end

  describe '#anonymize_user' do
    it 'replaces identifying data for non-admin users' do
      user = create(:user)
      anonymized_fields = [
        :email,
        :first_name,
        :last_name,
        :password
      ]
      expect {
        DatabaseAnonymizer.new.anonymize_user(user)
      }.to scrub_fields(user, anonymized_fields)
    end

    it 'does not replace data for a sample admin user' do
      user = create(:user)
      user.email = 'admin@example.com'
      expect { DatabaseAnonymizer.new.anonymize_user(user) }.to_not change { user.attributes }
    end

    it 'does not replace data for a sample organizer user' do
      user = create(:user)
      user.email = 'organizer@example.com'
      expect { DatabaseAnonymizer.new.anonymize_user(user) }.to_not change { user.attributes }
    end
  end

  describe '#anonymize_meetup_user' do
    it 'replaces identifying data from Meetup User data' do
      user = create(:meetup_user)
      anonymized_fields = [
        :full_name,
        :meetup_id
      ]
      expect {
        DatabaseAnonymizer.new.anonymize_meetup_user(user)
      }.to scrub_fields(user, anonymized_fields)
    end
  end

  describe '#anonymize_survey' do
    it 'replaces identifying data from Survey data' do
      survey = create(:survey)
      anonymized_fields = [
        :good_things,
        :bad_things,
        :other_comments
      ]
      expect {
        DatabaseAnonymizer.new.anonymize_survey(survey)
      }.to scrub_fields(survey, anonymized_fields)
    end
  end

  describe '#anonymize_rsvp' do
    it 'replaces identifying data from RSVP data' do
      rsvp = create(:rsvp, plus_one_host: Faker::Name.name)
      anonymized_fields = [
        :subject_experience,
        :teaching_experience,
        :job_details,
        :childcare_info,
        :plus_one_host,
        :dietary_info
      ]
      expect {
        DatabaseAnonymizer.new.anonymize_rsvp(rsvp)
      }.to scrub_fields(rsvp, anonymized_fields)
    end
  end

  describe '#anonymize_profile' do
    it 'replaces identifying data from the Profile' do
      profile = create(:user).profile
      profile.update(
        github_username: Faker::Hacker.noun.gsub('', '-'),
        twitter_username: 'fake_username'
      )
      anonymized_fields = [
        :other,
        :github_username,
        :twitter_username,
        :bio
      ]
      expect {
        DatabaseAnonymizer.new.anonymize_profile(profile)
      }.to scrub_fields(profile, anonymized_fields)
    end
  end

  describe '#anonymize_location' do
    it 'replaces sensitive data from the Location' do
      location = create(:location, notes: 'fun place', contact_info: 'someone important')
      anonymized_fields = [
        :notes,
        :contact_info
      ]
      expect {
        DatabaseAnonymizer.new.anonymize_location(location)
      }.to scrub_fields(location, anonymized_fields)
    end
  end

  describe '#anonymize_event_email' do
    it 'replaces sensitive data from the email' do
      event_email = create(:event_email, subject: 'hello', body: 'this is some info')
      anonymized_fields = [
        :subject,
        :body
      ]
      expect {
        DatabaseAnonymizer.new.anonymize_event_email(event_email)
      }.to scrub_fields(event_email, anonymized_fields)
    end
  end
end
