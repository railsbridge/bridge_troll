# frozen_string_literal: true

require 'rails_helper'

describe RsvpsController do
  def extract_rsvp_params(rsvp)
    accessible_attrs = RsvpPolicy.new(nil, Rsvp).permitted_attributes.map(&:to_s) + ['role_id']
    rsvp.attributes.select { |attr, _val| accessible_attrs.include?(attr) }.symbolize_keys
  end

  let(:event) { create(:event, title: 'The Best Railsbridge') }

  describe '#quick_destroy_confirm' do
    def make_request
      get :quick_destroy_confirm, params: { event_id: event.id, rsvp_id: rsvp.id, token: rsvp.token }
    end

    let!(:rsvp) do
      create(:rsvp,
             event: event,
             token: 'IamAtoken')
    end

    it 'assigns the rsvp' do
      make_request
      expect(assigns(:rsvp)).to eq(rsvp)
    end
  end

  describe 'when signed in' do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    describe 'when the event is in the past' do
      before do
        event.update(ends_at: 1.day.ago)
      end

      it 'does not allow RSVPing' do
        get :volunteer, params: { event_id: event.id }
        expect(response).to redirect_to(events_path)

        get :learn, params: { event_id: event.id }
        expect(response).to redirect_to(events_path)

        rsvp_params = extract_rsvp_params build(:student_rsvp, event: event)
        post :create, params: { event_id: event.id, rsvp: rsvp_params }
        expect(response).to redirect_to(events_path)
      end
    end

    describe 'when the event is closed' do
      before do
        event.update(open: false)
      end

      it 'does not allow RSVPing' do
        get :volunteer, params: { event_id: event.id }
        expect(response).to redirect_to(event_path(event))
        expect(flash[:error]).to be_present

        get :learn, params: { event_id: event.id }
        expect(response).to redirect_to(event_path(event))
        expect(flash[:error]).to be_present

        rsvp_params = extract_rsvp_params build(:student_rsvp, event: event)
        post :create, params: { event_id: event.id, rsvp: rsvp_params }
        expect(response).to redirect_to(event_path(event))
        expect(flash[:error]).to be_present
      end
    end

    describe '#volunteer' do
      it 'creates an RSVP for the volunteer role' do
        get :volunteer, params: { event_id: event.id }
        expect(assigns(:rsvp).role).to eq(Role::VOLUNTEER)
      end

      describe 'when the user has previously volunteered' do
        before do
          frontend_event = create(:event, course: create(:course, name: 'FRONTEND', title: 'Front End'))
          # frontend_Rsvp
          create(:rsvp,
                 user: user,
                 event: frontend_event,
                 subject_experience: 'I know about HTML',
                 teaching_experience: 'I have taught many websites',
                 job_details: 'Software Engineer')
        end

        let!(:rails_rsvp) do
          rails_event = create(:event, course: event.course)
          create(:rsvp,
                 user: user,
                 event: rails_event,
                 subject_experience: 'I know about Rails',
                 teaching_experience: 'I have taught many rubies',
                 job_details: 'Software Engineer')
        end

        it 'creates a new RSVP with details from their last RSVP for the same course' do
          get :volunteer, params: { event_id: event.id }
          rsvp = assigns(:rsvp)
          expect(rsvp.subject_experience).to eq(rails_rsvp.subject_experience)
          expect(rsvp.teaching_experience).to eq(rails_rsvp.teaching_experience)
          expect(rsvp.job_details).to eq(rails_rsvp.job_details)
        end

        context 'when the RSVP is for a course they have never attended' do
          before do
            course = create(:course, name: 'JAVASCRIPT', title: 'Intro to JavaScript')
            event.update(course_id: course.id)
          end

          it 'carries over only limited details' do
            get :volunteer, params: { event_id: event.id }
            rsvp = assigns(:rsvp)
            expect(rsvp.subject_experience).to be_blank
            expect(rsvp.teaching_experience).to be_blank
            expect(rsvp.job_details).to eq(rails_rsvp.job_details)
          end
        end
      end
    end

    describe '#learn' do
      it 'creates an RSVP for the student role' do
        get :learn, params: { event_id: event.id }
        expect(assigns(:rsvp).role).to eq(Role::STUDENT)
      end

      describe 'when the user has previously attended' do
        let!(:existing_rsvp) do
          create(:rsvp, user: user, job_details: 'Firetruck')
        end

        it 'creates a new RSVP with some details from their last RSVP' do
          get :learn, params: { event_id: event.id }
          rsvp = assigns(:rsvp)
          expect(rsvp.job_details).to eq(existing_rsvp.job_details)
        end
      end
    end

    describe 'when there is an existing RSVP for this user' do
      before do
        # create a rsvp
        create(:rsvp, user: user, event: event)
      end

      it 'redirects to the event page when trying to create a new RSVP' do
        get :volunteer, params: { event_id: event.id }
        expect(response).to redirect_to(event)

        get :learn, params: { event_id: event.id }
        expect(response).to redirect_to(event)
      end
    end

    describe 'when user is signing up for a region they have signed up for before' do
      before do
        create(:rsvp, user: user, event: event)
      end

      it 'does not show a warning' do
        get :learn, params: { event_id: event.id }
        expect(assigns(:show_new_region_warning)).to be_falsey
      end
    end

    describe "when user is signing up for a region they haven't signed up for before" do
      context 'when they have never signed up for an event' do
        it 'does not show a warning' do
          get :learn, params: { event_id: event.id }
          expect(assigns(:show_new_region_warning)).to be_falsey
        end
      end

      context 'when they have already signed up for some other region' do
        let!(:other_event) { create(:event, title: 'The other RailsBridge event') }

        before do
          create(:rsvp, user: user, event: event)
        end

        it 'shows them a warning to double check their location' do
          get :learn, params: { event_id: other_event.id }
          expect(assigns(:show_new_region_warning)).to be_truthy
        end
      end
    end
  end

  describe '#edit' do
    context 'as an organizer' do
      let(:organizer) { create(:user) }
      let(:organizer_rsvp) { create(:organizer_rsvp, event: event, user: organizer) }

      before do
        create(:event_session, event: event)
        sign_in organizer
      end

      it 'redirects to the event page' do
        get :edit, params: { event_id: event.id, id: organizer_rsvp.id }
        expect(response).to redirect_to(event)
      end
    end
  end

  describe '#create' do
    def make_request
      rsvp_params = extract_rsvp_params build(:rsvp, event: event)
      post :create, params: { event_id: event.id, rsvp: rsvp_params }
    end

    context 'when not logged in' do
      it_behaves_like 'an action that requires user log-in'

      it 'does not create any new rsvps' do
        expect do
          make_request
        end.not_to change(Rsvp, :count)
      end
    end

    context 'when there is no rsvp for the volunteer/event' do
      let(:user) { create(:user) }
      let(:rsvp_params) { extract_rsvp_params build(:rsvp, event: event) }

      before do
        sign_in user
      end

      def do_request
        post :create, params: { event_id: event.id, rsvp: rsvp_params, user: { gender: 'human' } }
      end

      it 'can set region affiliation' do
        expect(user.regions).to match_array([])

        expect do
          post :create, params: { event_id: event.id, rsvp: rsvp_params, user: { gender: 'human' }, affiliate_with_region: true }
        end.to change(Rsvp, :count).by(1)
        expect(user.reload.regions).to match_array([event.region])
      end

      context 'when the user is already part of the region' do
        before do
          user.regions << event.region
        end

        it 'can unset region affiliation' do
          expect do
            post :create, params: { event_id: event.id, rsvp: rsvp_params, user: { gender: 'human' } }
          end.to change(Rsvp, :count).by(1)
          expect(user.reload.regions).to match_array([])
        end

        it 'does nothing when trying to set the region' do
          expect do
            post :create, params: { event_id: event.id, rsvp: rsvp_params, user: { gender: 'human' }, affiliate_with_region: true }
          end.to change(Rsvp, :count).by(1)
          expect(user.reload.regions).to match_array([event.region])
        end
      end

      it 'generates a token for the RSVP' do
        allow(SecureRandom).to receive(:uuid).and_return('thisisatoken')
        do_request
        expect(Rsvp.last.token).to eq 'thisisatoken'
      end

      it 'allows the user to newly volunteer for an event' do
        expect { do_request }.to change(Rsvp, :count).by(1)
      end

      it 'redirects to the event page related to the rsvp with flash confirmation' do
        do_request
        expect(response).to redirect_to(event_path(event))
        expect(flash[:notice]).to match(/thanks/i)
      end

      it 'creates a rsvp that persists and is valid' do
        do_request
        expect(assigns[:rsvp]).to be_persisted
        expect(assigns[:rsvp]).to be_valid
      end

      it 'sets the new rsvp with the selected event, and current user' do
        do_request
        expect(assigns[:rsvp].user_id).to eq(assigns[:current_user].id)
        expect(assigns[:rsvp].event_id).to eq(event.id)
      end

      it "updates the user's gender" do
        do_request
        expect(user.reload.gender).to eq('human')
      end

      context 'when the event is not full' do
        before do
          event.update_attribute(:student_rsvp_limit, 2)
          create(:volunteer_rsvp, event: event)
          create(:volunteer_rsvp, event: event)
          create(:student_rsvp, event: event)
        end

        describe 'and a student rsvps' do
          it "adds the a newly rsvp'd student as a confirmed user" do
            rsvp_params = extract_rsvp_params build(:student_rsvp, event: event)
            expect do
              post :create, params: { event_id: event.id, rsvp: rsvp_params, user: { gender: 'human' } }
            end.to change(Rsvp, :count).by(1)

            expect(Rsvp.last.waitlist_position).to be_nil
            # gives a notice that does not mention the waitlist
            expect(flash[:notice]).to be_present
            expect(flash[:notice]).not_to match(/waitlist/i)
          end
        end
      end

      describe 'session attendance' do
        context 'when there is only one session' do
          it 'assigns the user to the session' do
            expect { do_request }.to change(Rsvp, :count).by(1)
            Rsvp.last.event_sessions.tap do |sessions|
              expect(sessions.count).to eq(1)
              expect(sessions.map(&:id)).to eq(event.event_sessions.map(&:id))
            end
          end
        end

        context 'when there are multiple sessions' do
          before do
            create(:event_session, event: event)
            create(:event_session, event: event, required_for_students: false)
            event.reload
          end

          context 'a student' do
            let(:rsvp_params) { extract_rsvp_params build(:student_rsvp, event: event) }

            it 'is assigned as attending all required sessions' do
              expect { do_request }.to change(Rsvp, :count).by(1)
              Rsvp.last.event_sessions.tap do |sessions|
                expect(sessions.count).to eq(2)
                expect(sessions.map(&:id)).to eq(event.event_sessions.where(required_for_students: true).pluck(:id))
              end
            end
          end

          context 'a volunteer' do
            before do
              rsvp_params[:event_session_ids] = [event.event_sessions.first.id]
            end

            it 'is assigned as attending only the desired sessions' do
              expect { do_request }.to change(Rsvp, :count).by(1)
              Rsvp.last.event_sessions do |sessions|
                expect(sessions.count).to eq(1)
                expect(sessions.map(&:id)).to eq(event.event_sessions.map(&:id))
              end
            end
          end
        end
      end

      context 'when the event is full of students' do
        before do
          event.update_attribute(:student_rsvp_limit, 2)
          create(:student_rsvp, event: event)
          create(:student_rsvp, event: event)
        end

        describe 'and a student rsvps' do
          let(:rsvp_params) do
            extract_rsvp_params(build(:student_rsvp, event: event, role: Role::STUDENT))
          end

          def student_rsvp
            post :create, params: { event_id: event.id, rsvp: rsvp_params, user: { gender: 'human' } }
          end

          it 'adds the student to the waitlist' do
            expect { student_rsvp }.to change(Rsvp, :count).by(1)
            expect(Rsvp.last.waitlist_position).to eq(1)
            # gives a notice that mentions the waitlist
            expect(flash[:notice]).to match(/waitlist/i)
          end

          describe 'then another student rsvps' do
            before do
              student_rsvp
              sign_out user
              sign_in create(:user)
            end

            it 'adds the student the waitlist after the original student' do
              expect do
                student_rsvp
              end.to change(Rsvp, :count).by(1)

              expect(Rsvp.last.waitlist_position).to eq(2)
            end
          end
        end

        describe 'and a volunteer rsvps' do
          let(:rsvp_params) { extract_rsvp_params build(:volunteer_rsvp, event: event, role: Role::VOLUNTEER) }

          it 'adds the volunteer as confirmed' do
            expect do
              post :create, params: { event_id: event.id, rsvp: rsvp_params, user: { gender: 'human' } }
            end.to change(Rsvp, :count).by(1)
            expect(Rsvp.last.waitlist_position).to be_nil
          end
        end
      end

      context 'when the event is full of volunteers' do
        before do
          allow_any_instance_of(Event).to receive(:volunteers_at_limit?).and_return(true)
        end

        describe 'and a volunteer rsvps' do
          let(:rsvp_params) { extract_rsvp_params build(:volunteer_rsvp, event: event, role: Role::VOLUNTEER) }

          def volunteer_rsvp
            post :create, params: { event_id: event.id, rsvp: rsvp_params, user: { gender: 'human' } }
          end

          it 'adds the volunteer to the waitlist' do
            expect { volunteer_rsvp }.to change(Rsvp, :count).by(1)
            expect(Rsvp.last.waitlist_position).to eq(1)
            # gives a notice that mentions the waitlist
            expect(flash[:notice]).to match(/waitlist/i)
          end

          describe 'then another volunteer rsvps' do
            before do
              volunteer_rsvp
              sign_out user
              sign_in create(:user)
            end

            it 'adds the volunteer the waitlist after the original student' do
              expect do
                volunteer_rsvp
              end.to change(Rsvp, :count).by(1)

              expect(Rsvp.last.waitlist_position).to eq(2)
            end
          end
        end

        describe 'and a student rsvps' do
          let(:rsvp_params) { extract_rsvp_params build(:student_rsvp, event: event, role: Role::STUDENT) }

          it 'adds the student as confirmed' do
            expect do
              post :create, params: { event_id: event.id, rsvp: rsvp_params, user: { gender: 'human' } }
            end.to change(Rsvp, :count).by(1)
            expect(Rsvp.last.waitlist_position).to be_nil
          end
        end
      end

      describe 'childcare information' do
        context 'when childcare_needed is unchecked' do
          before do
            post :create, params: { event_id: event.id, rsvp: rsvp_params.merge(
              needs_childcare: '0', childcare_info: 'goodbye, cruel world'
            ), user: { gender: 'human' } }
          end

          it 'clears childcare_info' do
            expect(assigns[:rsvp].childcare_info).to be_blank
          end
        end

        context 'when childcare_needed is checked' do
          let(:child_info) { "Johnnie Kiddo, 7\nJane Kidderino, 45" }

          it 'hases validation errors for blank childcare_info' do
            post :create, params: { event_id: event.id, rsvp: rsvp_params.merge(
              needs_childcare: '1', childcare_info: ''
            ) }
            expect(assigns[:rsvp]).to have(1).errors_on(:childcare_info)
          end

          it 'updates sets childcare_info when not blank' do
            post :create, params: { event_id: event.id, rsvp: rsvp_params.merge(
              needs_childcare: '1',
              childcare_info: child_info
            ), user: { gender: 'human' } }

            expect(assigns[:rsvp].childcare_info).to eq(child_info)
          end

          context 'the email' do
            let(:organizers) { create_list :user, 2 }

            before do
              event.organizers = organizers
            end

            it 'is sent to organizers' do
              expect do
                post :create, params: { event_id: event.id, rsvp: rsvp_params.merge(
                  needs_childcare: '1',
                  childcare_info: child_info
                ), user: { gender: 'human' } }
              end.to change(ActionMailer::Base.deliveries, :count).by(2)
              # This action also sends a confirmation email to the student.
            end

            it 'has the correct recipients' do
              post :create, params: { event_id: event.id, rsvp: rsvp_params.merge(
                needs_childcare: '1',
                childcare_info: child_info
              ), user: { gender: 'human' } }

              recipients = JSON.parse(ActionMailer::Base.deliveries.last.header['X-SMTPAPI'].to_s)['to']
              expect(recipients).to match_array(event.organizers.map(&:email))
            end
          end
        end
      end

      describe 'dietary restriction information' do
        context 'when a dietary restriction is checked' do
          it 'adds a dietary restriction' do
            all_rsvp_params = rsvp_params.merge(dietary_restriction_diets: ['vegan'])
            expect do
              post :create, params: { event_id: event.id, rsvp: all_rsvp_params, user: { gender: 'human' } }
            end.to change(DietaryRestriction, :count).by(1)

            expect(Rsvp.last.dietary_restrictions.map(&:restriction)).to eq(['vegan'])
          end
        end
      end
    end

    context 'when there is already a rsvp for the volunteer/event' do
      # the user may have canceled, changed his/her mind, and decided to volunteer again
      let(:user) { create(:user) }
      let!(:rsvp_params) do
        rsvp = create(:rsvp, user: user, event: event)
        extract_rsvp_params rsvp
      end

      before do
        sign_in user
      end

      it 'does not create any new rsvps' do
        expect do
          post :create, params: { event_id: event.id, rsvp: rsvp_params, user: { gender: 'human' } }
        end.not_to change(Rsvp, :count)
      end
    end
  end

  describe '#update' do
    let(:user) { create(:user) }
    let(:my_rsvp) { create(:rsvp, user: user, event: event) }
    let(:other_rsvp) { create(:rsvp, event: event) }
    let(:rsvp_params) do
      { subject_experience: 'Abracadabra' }
    end

    before do
      sign_in user
    end

    it 'updates rsvps owned by the logged in user' do
      expect do
        put :update, params: { event_id: event.id, id: my_rsvp.id, rsvp: rsvp_params, user: { gender: 'human' } }
      end.to change { my_rsvp.reload.subject_experience }.to(rsvp_params[:subject_experience])

      expect(response).to redirect_to(event)
    end

    it 'can update region affiliation' do
      expect(user.regions).to match_array([])

      put :update, params: { event_id: event.id, id: my_rsvp.id, rsvp: rsvp_params, user: { gender: 'human' }, affiliate_with_region: true }
      expect(user.reload.regions).to match_array([event.region])

      # doing it again to make sure we don't try to set it twice
      put :update, params: { event_id: event.id, id: my_rsvp.id, rsvp: rsvp_params, user: { gender: 'human' }, affiliate_with_region: true }
      expect(user.reload.regions).to match_array([event.region])

      put :update, params: { event_id: event.id, id: my_rsvp.id, rsvp: rsvp_params, user: { gender: 'human' } }
      expect(user.reload.regions).to match_array([])
    end

    it 'cannot update rsvps owned by other users' do
      expect do
        put :update, params: { event_id: event.id, id: other_rsvp.id, rsvp: rsvp_params, user: { gender: 'human' } }
      end.not_to(change { other_rsvp.reload.subject_experience })

      expect(response).not_to be_successful
    end
  end

  describe '#destroy' do
    context 'when an organizer deletes by id' do
      before do
        user = create(:user)
        sign_in user
        create(:organizer_rsvp, event: event, user: user)
      end

      let!(:rsvp) { create(:student_rsvp, event: event, user: create(:user)) }

      it 'destroys the rsvp and reorder the waitlist' do
        waitlist_manager = instance_double(WaitlistManager, reorder_waitlist!: true)
        allow(WaitlistManager).to receive(:new).and_return(waitlist_manager)

        expect(waitlist_manager).to receive(:reorder_waitlist!)

        expect do
          delete :destroy, params: { event_id: rsvp.event.id, id: rsvp.id }
        end.to change(Rsvp, :count).by(-1)

        expect do
          rsvp.reload
        end.to raise_error(ActiveRecord::RecordNotFound)
        expect(flash[:notice]).to match(/no longer signed up/i)
      end
    end

    context 'when not signed in and an RSVP token is available' do
      let!(:rsvp) { create(:student_rsvp, event: event, token: 'iamatoken') }

      it 'destroys the rsvp and reorder the waitlist' do
        expect do
          delete :destroy, params: { event_id: event.id, id: rsvp.id, token: rsvp.token }
        end.to change(Rsvp, :count).by(-1)

        expect { rsvp.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when using an invalid RSVP token' do
      before do
        user = create(:user)
        sign_in user
      end

      it 'does nothing' do
        expect do
          delete :destroy, params: { event_id: event.id, id: 123, token: 'abcdefg' }
        end.not_to change(Rsvp, :count)

        expect(flash[:notice]).to match(/You are not signed up/i)
        expect(response).to be_redirect
      end
    end

    context 'when a user has an existing rsvp' do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it 'destroys the rsvp' do
        rsvp = create(:student_rsvp, event: event, user: user)

        expect do
          delete :destroy, params: { event_id: rsvp.event.id, id: rsvp.id }
        end.to change(Rsvp, :count).by(-1)

        expect do
          rsvp.reload
        end.to raise_error(ActiveRecord::RecordNotFound)

        expect(flash[:notice]).to match(/no longer signed up/i)
      end

      describe 'as a student' do
        before do
          rsvp
          event.update_attribute(:student_rsvp_limit, 2)
          create(:student_rsvp, event: event)
          waitlisted
        end

        let(:rsvp) { create(:student_rsvp, event: event, user: user) }
        let(:waitlisted) { create(:student_rsvp, event: event, waitlist_position: 1) }

        it 'reorders the student waitlist' do
          expect(event.reload).to be_students_at_limit
          delete :destroy, params: { event_id: rsvp.event.id, id: rsvp.id }

          expect(waitlisted.reload.waitlist_position).to be_nil
        end
      end

      describe 'as a volunteer' do
        before do
          rsvp

          event.update_attribute(:volunteer_rsvp_limit, 2)
          create(:volunteer_rsvp, event: event)
          waitlisted
        end

        let(:waitlisted) { create(:volunteer_rsvp, event: event, waitlist_position: 1) }
        let(:rsvp) { create(:volunteer_rsvp, event: event, user: user) }

        it 'reorders the volunteer waitlist' do
          expect(event.reload).to be_volunteers_at_limit
          delete :destroy, params: { event_id: rsvp.event.id, id: rsvp.id }

          expect(waitlisted.reload.waitlist_position).to be_nil
        end
      end
    end

    context 'when there is no RSVP for this user' do
      before do
        user = create(:user)
        sign_in user
      end

      it 'notifies the user s/he has not signed up to volunteer for the event' do
        expect do
          delete :destroy, params: { event_id: 3_298_423, id: 29_101 }
        end.to change(Rsvp, :count).by(0)
        expect(flash[:notice]).to match(/You are not signed up/i)
      end
    end
  end
end
