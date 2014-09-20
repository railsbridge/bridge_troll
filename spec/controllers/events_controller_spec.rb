require 'rails_helper'

describe EventsController do
  before do
    @event = create(:event, title: 'DonutBridge')
  end

  describe "GET index" do
    it "successfully assigns upcoming events" do
      get :index
      response.should be_success
      assigns(:events).should == [@event]
    end

    describe "when rendering views" do
      render_views

      describe "when external events are present" do
        before do
          event = create(:event, title: 'PastBridge', time_zone: 'Alaska')
          event.update_attributes(starts_at: 5.days.ago, ends_at: 4.days.ago)
          create(:external_event, name: 'SalsaBridge', starts_at: 3.days.ago, ends_at: 2.days.ago)
        end

        it 'renders a combination of internal and external events' do
          get :index
          response.body.should include('PastBridge')
          response.body.should include('DonutBridge')
          response.body.should include('SalsaBridge')
        end
      end

      describe "#allow_student_rsvp?" do
        let(:attend_text) { 'Attend' }

        it "shows an 'Attend' button when allowing student RSVP" do
          @event.update_attribute(:allow_student_rsvp, true)
          get :index
          response.body.should include(attend_text)
        end

        it "hides the 'Attend' button when not allowing student RSVP" do
          @event.update_attribute(:allow_student_rsvp, false)
          get :index
          response.body.should_not include(attend_text)
        end
      end
    end
  end

  describe "GET show" do
    it "successfully assigns the event" do
      get :show, id: @event.id
      assigns(:event).should == @event
      response.should be_success
    end

    describe "when rendering views" do
      render_views
      before do
        @event.location = create(:location, name: 'Carbon Nine')
        @event.save!
      end

      it "includes the location" do
        get :show, id: @event.id
        response.body.should include('Carbon Nine')
      end

      describe "#allow_student_rsvp?" do
        let(:attend_text) { 'Attend' }
        before do
          sign_in create(:user)
        end

        it "shows an 'Attend' button when allowing student RSVP" do
          @event.update_attribute(:allow_student_rsvp, true)
          get :show, id: @event.id
          response.body.should include(attend_text)
        end

        it "hides the 'Attend' button when not allowing student RSVP" do
          @event.update_attribute(:allow_student_rsvp, false)
          get :show, id: @event.id
          response.body.should_not include(attend_text)
        end
      end

      context "when no volunteers or students are attending" do
        it "shows a message about the lack of volunteers" do
          get :show, id: @event.id
          response.body.should include('No volunteers')
        end

        it "shows a message about the lack of students" do
          get :show, id: @event.id
          response.body.should include('No students')
        end
      end

      context "when volunteers are attending" do
        before do
          volunteer = create(:user, first_name: 'Ron', last_name: 'Swanson')
          create(:rsvp, event: @event, user: volunteer, role: Role::VOLUNTEER)
        end

        it "shows the volunteer somewhere on the page" do
          get :show, id: @event.id
          response.body.should include('Ron Swanson')
        end
      end

      context "when students are attending" do
        before do
          student = create(:user, first_name: 'Jane', last_name: 'Fontaine')
          create(:student_rsvp, event: @event, user: student, role: Role::STUDENT)
        end

        it "shows the student somewhere on the page" do
          get :show, id: @event.id
          response.body.should include('Jane Fontaine')
        end

        context "and there is no waitlist" do
          it "doesn't have the waitlist header" do
            get :show, id: @event.id
            response.body.should_not include('waitlist')
          end
        end

        context "and there is a waitlist" do
          before do
            @event.update_attribute(:student_rsvp_limit, 1)
            student = create(:user, first_name: 'Sandy', last_name: 'Sontaine')
            create(:student_rsvp, event: @event, user: student, role: Role::STUDENT, waitlist_position: 1)
          end

          it "shows waitlisted students in a waitlist section" do
            get :show, id: @event.id
            response.body.should include('waitlisted')
            response.body.should include('Sandy Sontaine')
          end
        end
      end
    end
  end

  describe "GET new" do
    def make_request
      get :new
    end

    it_behaves_like "an action that requires user log-in"

    context "when a user is logged in" do
      before do
        @user = create(:user, time_zone: 'Alaska')
        sign_in @user
      end

      it "successfully assigns an event" do
        get :new
        assigns(:event).should be_new_record
        response.should be_success
      end

      it "uses the logged in user's time zone as the event's time zone" do
        get :new
        assigns(:event).time_zone.should == 'Alaska'
      end
    end
  end

  describe "GET edit" do
    def make_request
      get :edit, :id => @event.id
    end

    it_behaves_like "an event action that requires an organizer"

    context "organizer is logged in" do
      before do
        user = create(:user)
        @event.organizers << user
        sign_in user
      end

      it "successfully assigns the event" do
        make_request
        assigns(:event).should == @event
        response.should be_success
      end
    end
  end

  describe "GET levels" do
    it "succeeds without requiring any permissions" do
      get :levels, :id => @event.id
      response.should be_success
    end
  end

  describe "POST create" do
    def make_request(params = {})
      post :create, params
    end

    it_behaves_like "an action that requires user log-in"

    context "when a user is logged in" do
      before do
        @user = create(:user)
        sign_in @user
      end

      describe "with valid params" do
        let(:create_params) {
          {
            "event" => {
              "title" => "Party Zone",
              "time_zone" => "Alaska",
              "student_rsvp_limit" => 100,
              "event_sessions_attributes" => {
                "0" => {
                  "name" => 'I am good at naming sessions',
                  "starts_at(1i)" => "2053",
                  "starts_at(2i)" => "1",
                  "starts_at(3i)" => "12",
                  "starts_at(4i)" => "12",
                  "starts_at(5i)" => "30",
                  "ends_at(1i)" => "2053",
                  "ends_at(2i)" => "1",
                  "ends_at(3i)" => "12",
                  "ends_at(4i)" => "22",
                  "ends_at(5i)" => "30"
                }
              },
              "location_id" => "1",
              "details" => "sdfasdfasdf"
            }
          }
        }

        it "creates a new event" do
          expect {
            make_request(create_params)
          }.to change(Event, :count).by(1)
        end

        it "sets the event's session times in the event's time zone" do
          make_request(create_params)
          Event.last.event_sessions.last.starts_at.zone.should == 'AKST'
        end

        it "adds the current user to the organizers of the event" do
          make_request(create_params)
          Event.last.organizers.should include(@user)
        end

        it "redirects to the new event's page" do
          make_request(create_params)
          response.should redirect_to event_path(Event.last)
        end

        it "shows a success message" do
          make_request(create_params)
          flash[:notice].should be_present
        end

        context "but the user is flagged as a spammer" do
          before do
            @user.update_attribute(:spammer, true)
          end

          it "sends no email and flags the event as spam after creation" do
            expect {
              make_request(create_params)
            }.not_to change(ActionMailer::Base.deliveries, :count)
            Event.last.should be_spam
          end
        end

        describe "notifying publishers of events" do
          before do
            @user.update_attributes(first_name: 'Nitro', last_name: 'Boost')
            @admin = create(:user, admin: true)
            @publisher = create(:user, publisher: true)
          end

          let(:recipients) { JSON.parse(ActionMailer::Base.deliveries.last.header['X-SMTPAPI'].to_s)['to'] }

          it "sends an email to all admins/publishers on event creation" do
            expect {
              make_request(create_params)
            }.to change(ActionMailer::Base.deliveries, :count).by(1)

            mail = ActionMailer::Base.deliveries.last
            mail.subject.should include('Nitro Boost')
            mail.subject.should include('Party Zone')
            mail.body.should include('Party Zone')

            recipients.should =~ [@admin.email, @publisher.email]
          end
        end
      end

      describe "with invalid params" do
        let(:invalid_params) {
          {
            "event" => {
              "title" => "Party Zone"
            }
          }
        }

        it "renders :new without creating an event" do
          expect { make_request(invalid_params) }.to_not change { Event.count }

          assigns(:event).should be_new_record
          response.should be_success
          response.should render_template('events/new')
        end
      end
    end
  end

  describe "GET organize" do
    def make_request
      get :organize, id: @event.id
    end

    it_behaves_like "an event action that requires an organizer"

    context "organizer is logged in" do
      before do
        user = create(:user)
        @event.organizers << user
        sign_in user
      end

      it "should be successful" do
        make_request
        response.should be_success
      end

      it 'assigns the childcare requests' do
        make_request
        expect(assigns(:childcare_requests)).to eq @event.rsvps_with_childcare
      end

      describe "checked in user counts" do
        before do
          @event.update_attribute(:student_rsvp_limit, 2)
          @session1 = @event.event_sessions.first
          @session2 = create(:event_session, event: @event)

          def deep_copy(o)
            Marshal.load(Marshal.dump(o))
          end

          expectation = {
            Role::VOLUNTEER.id => {
              @session1.id => [],
              @session2.id => []
            },
            Role::STUDENT.id => {
              @session1.id => [],
              @session2.id => []
            }
          }
          @rsvps = deep_copy(expectation)
          @checkins = deep_copy(expectation)

          def add_session_rsvp(rsvp, session, checked_in)
            create(:rsvp_session, rsvp: rsvp, event_session: session, checked_in: checked_in)
            @rsvps[rsvp.role.id][session.id] << rsvp
            @checkins[rsvp.role.id][session.id] << rsvp if checked_in
          end

          rsvp1 = create(:volunteer_rsvp, event: @event)
          add_session_rsvp(rsvp1, @session1, true)
          add_session_rsvp(rsvp1, @session2, true)

          rsvp2 = create(:volunteer_rsvp, event: @event)
          add_session_rsvp(rsvp2, @session1, true)
          add_session_rsvp(rsvp2, @session2, false)

          rsvp3 = create(:volunteer_rsvp, event: @event)
          add_session_rsvp(rsvp3, @session1, true)

          rsvp4 = create(:student_rsvp, event: @event)
          add_session_rsvp(rsvp4, @session2, true)

          rsvp5 = create(:student_rsvp, event: @event)
          add_session_rsvp(rsvp5, @session2, true)

          waitlisted = create(:student_rsvp, event: @event, waitlist_position: 1)
          create(:rsvp_session, rsvp: waitlisted, event_session: @session2, checked_in: false)
        end

        it "sends checked in user counts to the view" do
          make_request
          assigns(:checkin_counts)[Role::VOLUNTEER.id][:rsvp].should == {
            @session1.id => @rsvps[Role::VOLUNTEER.id][@session1.id].length,
            @session2.id => @rsvps[Role::VOLUNTEER.id][@session2.id].length
          }
          assigns(:checkin_counts)[Role::VOLUNTEER.id][:checkin].should == {
            @session1.id => @checkins[Role::VOLUNTEER.id][@session1.id].length,
            @session2.id => @checkins[Role::VOLUNTEER.id][@session2.id].length
          }

          assigns(:checkin_counts)[Role::STUDENT.id][:rsvp].should == {
            @session1.id => @rsvps[Role::STUDENT.id][@session1.id].length,
            @session2.id => @rsvps[Role::STUDENT.id][@session2.id].length
          }
          assigns(:checkin_counts)[Role::STUDENT.id][:checkin].should == {
            @session1.id => @checkins[Role::STUDENT.id][@session1.id].length,
            @session2.id => @checkins[Role::STUDENT.id][@session2.id].length
          }
        end
      end
    end
  end

  describe "PUT update" do
    def make_request(params = {})
      put :update, id: @event.id, event: params
    end

    it_behaves_like "an event action that requires an organizer"

    context "organizer is logged in" do
      before do
        user = create(:user)
        @event.organizers << user
        sign_in user
      end

      describe "with valid params" do
        let(:update_params) {
          {
            "title" => "Updated event title",
            "details" => "Updated event details",
            "time_zone" => "Caracas"
          }
        }

        it "updates the event" do
          make_request(update_params)
          @event.reload
          @event.title.should == "Updated event title"
          @event.details.should == "Updated event details"
        end

        it "sets the event's session times in the event's time zone" do
          make_request(update_params)
          event_session = @event.reload.event_sessions.last
          event_session.starts_at.zone.should == 'VET'
        end

        it "redirects to the event page" do
          make_request(update_params)
          response.should redirect_to event_path(@event)
        end

        it "shows a success message" do
          make_request(update_params)
          flash[:notice].should be_present
        end
      end

      describe "with invalid params" do
        let(:invalid_params) {
          {
            "title" => ""
          }
        }

        it "re-renders the edit form" do
          make_request(invalid_params)
          assigns(:event).should == @event
          response.should be_unprocessable
          response.should render_template('events/edit')
        end
      end
    end
  end

  describe "DELETE destroy" do
    def make_request
      delete :destroy, :id => @event.id
    end

    it_behaves_like "an event action that requires an organizer"

    context "organizer is logged in" do
      before do
        user = create(:user)
        @event.organizers << user
        sign_in user
      end

      it "destroys the event" do
        make_request
        Event.find_by_id(@event.id).should be_nil
      end

      it "redirects to the events page" do
        make_request
        response.should redirect_to events_path
      end
    end
  end

  describe "GET past_events" do
    before do
      @future_event = create(:event, title: 'FutureBridge', starts_at: 5.days.from_now, ends_at: 6.days.from_now, time_zone: 'Alaska')
      @future_external_event = create(:external_event, name: 'FutureExternalBridge', starts_at: 3.days.from_now, ends_at: 4.days.from_now)
      @past_event = create(:event, title: 'PastBridge', time_zone: 'Alaska')
      @past_event.update_attributes(starts_at: 5.days.ago, ends_at: 4.days.ago)
      @past_external_event = create(:external_event, name: 'PastExternalBridge', starts_at: 3.days.ago, ends_at: 2.days.ago)
      @unpublished_event = create(:event, starts_at: 5.days.from_now, ends_at: 6.days.from_now, published: false)
    end

    it 'renders published past events as json' do
      get :past_events, format: 'json'
      response.should be_success

      result_titles = JSON.parse(response.body).map { |e| e['title'] }
      result_titles.should == [@past_event, @past_external_event].map(&:title)
    end
  end

  describe "GET all_events" do
    before do
      @event.delete
      @future_event = create(:event, title: 'FutureBridge', starts_at: 5.days.from_now, ends_at: 6.days.from_now, time_zone: 'Alaska')
      @future_external_event = create(:external_event, name: 'FutureExternalBridge', starts_at: 3.days.from_now, ends_at: 2.days.from_now)
      @past_event = create(:event, title: 'PastBridge', time_zone: 'Alaska')
      @past_event.update_attributes(starts_at: 5.days.ago, ends_at: 4.days.ago)
      @past_external_event = create(:external_event, name: 'PastExternalBridge', starts_at: 3.days.ago, ends_at: 2.days.ago)
      @unpublished_event = create(:event, starts_at: 5.days.from_now, ends_at: 6.days.from_now, published: false)
    end

    it 'renders all published events as json' do
      get :all_events, format: 'json'
      result_titles = JSON.parse(response.body).map { |e| e['title'] }
      result_titles.should == [@past_event, @past_external_event, @future_external_event, @future_event].map(&:title)
    end
  end

  describe "GET unpublished" do
    before do
      @chapter1 = @event.chapter
      @chapter1.update_attributes(name: 'RailsBridge Shellmound')
      @chapter2 = create(:chapter, name: 'RailsBridge Meriloft')

      user_none = create(:user)

      user_chapter1 = create(:user)
      user_chapter1.chapters << @chapter1

      user_chapter2 = create(:user)
      user_chapter2.chapters << @chapter2

      user_both_chapters = create(:user)
      user_both_chapters.chapters << @chapter1
      user_both_chapters.chapters << @chapter2

      user_no_email = create(:user, allow_event_email: false)
      user_no_email.chapters << @chapter1

      sign_in create(:user, publisher: true)
    end

    it "assigns a hash of chapter/user counts" do
      get :unpublished

      assigns(:chapter_user_counts).should == {
        @chapter1.id => 2,
        @chapter2.id => 2
      }
    end
  end

  describe "POST publish" do
    before do
      this_chapter = @event.chapter
      this_chapter.update_attributes(name: 'RailsBridge Shellmound')
      other_chapter = create(:chapter, name: 'RailsBridge Meriloft')

      @user_none = create(:user)

      @user_this_chapter = create(:user)
      @user_this_chapter.chapters << this_chapter

      @user_no_email = create(:user, allow_event_email: false)
      @user_no_email.chapters << this_chapter

      @user_other_chapter = create(:user)
      @user_other_chapter.chapters << other_chapter

      @user_both_chapters = create(:user)
      @user_both_chapters.chapters << this_chapter
      @user_both_chapters.chapters << other_chapter

      sign_in create(:user, publisher: true)
    end

    let(:recipients) { JSON.parse(ActionMailer::Base.deliveries.last.header['X-SMTPAPI'].to_s)['to'] }

    it 'sets the event to "published" and mails every user that is associated with this chapter' do
      expect {
        post :publish, id: @event.id
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
      @event.reload.should be_published

      recipients.should =~ [@user_this_chapter.email, @user_both_chapters.email]

      mail = ActionMailer::Base.deliveries.last
      mail.subject.should include(@event.chapter.name)
      mail.body.should include(@event.title)
    end

    it 'sends no emails if the event has email_on_approval set to false' do
      @event.update_attribute(:email_on_approval, false)
      expect {
        post :publish, id: @event.id
      }.not_to change(ActionMailer::Base.deliveries, :count)
      @event.reload.should be_published
    end
  end
end
