# frozen_string_literal: true

require 'rails_helper'

describe DatabaseAnonymizer do
  RSpec::Matchers.define :scrub_fields do |record, fields|
    match do |actual|
      original_attributes = record.attributes.slice(*fields.map(&:to_s))
      raise 'Could not determine original attributes' if original_attributes.blank?

      actual.call

      processed_attributes = record.attributes.slice(*fields.map(&:to_s))

      @unscrubbed_attributes = []
      original_attributes.each do |key, value|
        @unscrubbed_attributes << key if processed_attributes[key] == value
      end

      @unscrubbed_attributes.empty?
    end

    failure_message do |_actual|
      <<~FAILURE_MESSAGE
        Did not seem to scrub these #{record.class} attributes:
        #{@unscrubbed_attributes.join(', ')}
      FAILURE_MESSAGE
    end

    def supports_block_expectations?
      true
    end
  end

  describe '#anonymize_database' do
    let(:logger) { Logger.new($stdout) }
    let(:anonymizer) { described_class.new(logger) }
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
      anonymized_fields = %i[
        email
        first_name
        last_name
        password
      ]
      expect do
        described_class.new.anonymize_user(user)
      end.to scrub_fields(user, anonymized_fields)
    end

    it 'does not replace data for a sample admin user' do
      user = create(:user)
      user.email = 'admin@example.com'
      expect { described_class.new.anonymize_user(user) }.not_to(change { user.attributes })
    end

    it 'does not replace data for a sample organizer user' do
      user = create(:user)
      user.email = 'organizer@example.com'
      expect { described_class.new.anonymize_user(user) }.not_to(change { user.attributes })
    end
  end

  describe '#anonymize_meetup_user' do
    it 'replaces identifying data from Meetup User data' do
      user = create(:meetup_user)
      anonymized_fields = %i[
        full_name
        meetup_id
      ]
      expect do
        described_class.new.anonymize_meetup_user(user)
      end.to scrub_fields(user, anonymized_fields)
    end
  end

  describe '#anonymize_survey' do
    it 'replaces identifying data from Survey data' do
      survey = create(:survey)
      anonymized_fields = %i[
        good_things
        bad_things
        other_comments
      ]
      expect do
        described_class.new.anonymize_survey(survey)
      end.to scrub_fields(survey, anonymized_fields)
    end
  end

  describe '#anonymize_rsvp' do
    it 'replaces identifying data from RSVP data' do
      rsvp = create(:rsvp, plus_one_host: Faker::Name.name)
      anonymized_fields = %i[
        subject_experience
        teaching_experience
        job_details
        childcare_info
        plus_one_host
        dietary_info
      ]
      expect do
        described_class.new.anonymize_rsvp(rsvp)
      end.to scrub_fields(rsvp, anonymized_fields)
    end
  end

  describe '#anonymize_profile' do
    it 'replaces identifying data from the Profile' do
      profile = create(:user).profile
      profile.update(
        github_username: Faker::Hacker.noun.gsub('', '-'),
        twitter_username: 'fake_username'
      )
      anonymized_fields = %i[
        other
        github_username
        twitter_username
        bio
      ]
      expect do
        described_class.new.anonymize_profile(profile)
      end.to scrub_fields(profile, anonymized_fields)
    end
  end

  describe '#anonymize_location' do
    it 'replaces sensitive data from the Location' do
      location = create(:location, notes: 'fun place', contact_info: 'someone important')
      anonymized_fields = %i[
        notes
        contact_info
      ]
      expect do
        described_class.new.anonymize_location(location)
      end.to scrub_fields(location, anonymized_fields)
    end
  end

  describe '#anonymize_event_email' do
    it 'replaces sensitive data from the email' do
      event_email = create(:event_email, subject: 'hello', body: 'this is some info')
      anonymized_fields = %i[
        subject
        body
      ]
      expect do
        described_class.new.anonymize_event_email(event_email)
      end.to scrub_fields(event_email, anonymized_fields)
    end
  end
end
