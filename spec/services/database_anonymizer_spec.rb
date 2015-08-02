require 'rails_helper'

describe DatabaseAnonymizer do
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
      expect { DatabaseAnonymizer.new.anonymize_user(user) }.to change{ [user.email,
                                                                     user.first_name,
                                                                     user.last_name,
                                                                     user.gender,
                                                                     user.password] }
    end

    it 'does not replace data for a sample admin user' do
      user = create(:user)
      user.email = 'admin@example.com'
      expect { DatabaseAnonymizer.new.anonymize_user(user) }.to_not change{ [user.email, user.password] }
    end

    it 'does not replace data for a sample organizer user' do
      user = create(:user)
      user.email = 'organizer@example.com'
      expect { DatabaseAnonymizer.new.anonymize_user(user) }.to_not change{ [user.email, user.password] }
    end
  end

  describe '#anonymize_meetup_user' do
    it 'replaces identifying data from Meetup User data' do
      user = create(:meetup_user)
      expect{ DatabaseAnonymizer.new.anonymize_meetup_user(user) }.to change{ [user.full_name,
                                                                         user.meetup_id ] }
    end
  end

  describe '#anonymize_survey' do
    it 'replaces identifying data from Survey data' do
      survey = create(:survey)
      expect{ DatabaseAnonymizer.new.anonymize_survey(survey) }.to change{ [ survey.good_things,
                                                                         survey.bad_things,
                                                                         survey.other_comments ] }
    end
  end

  describe '#anonymize_rsvp' do
    it 'replaces identifying data from RSVP data' do
      rsvp = create(:rsvp)
      expect{ DatabaseAnonymizer.new.anonymize_rsvp(rsvp) }.to change{ [ rsvp.subject_experience,
                                                                     rsvp.teaching_experience,
                                                                     rsvp.job_details,
                                                                     rsvp.childcare_info,
                                                                     rsvp.plus_one_host,
                                                                     rsvp.dietary_info ] }
    end
  end

  describe '#anonymize_profile' do
    it 'replaces identifying data from the Profile' do
      profile = create(:user).profile
      profile.update_attribute(:github_username, Faker::Hacker.noun.gsub('', '-'))
      expect{ DatabaseAnonymizer.new.anonymize_profile(profile) }.to change{ [ profile.other,
                                                                           profile.github_username,
                                                                           profile.bio ]}
    end
  end

  describe '#anonymize_location' do
    it 'replaces sensitive data from the Location' do
      location = create(:location, notes: 'fun place', contact_info: 'someone important')
      expect{ DatabaseAnonymizer.new.anonymize_location(location) }.to change{ [ location.notes,
                                                                           location.contact_info ]}
    end
  end

  describe '#anonymize_event_email' do
    it 'replaces sensitive data from the email' do
      event_email = create(:event_email, subject: 'hello', body: 'this is some info')
      expect{ DatabaseAnonymizer.new.anonymize_event_email(event_email) }.to change{ [ event_email.subject,
                                                                           event_email.body ]}
    end
  end
end
