require 'rails_helper'

describe EventsController do
  describe "GET index" do
    let!(:event) { create(:event, title: 'DonutBridge') }

    it "successfully assigns upcoming events" do
      get :index
      response.should be_success
      assigns(:events).should == [event]
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
          event.update_attribute(:allow_student_rsvp, true)
          get :index
          response.body.should include(attend_text)
        end

        it "hides the 'Attend' button when not allowing student RSVP" do
          event.update_attribute(:allow_student_rsvp, false)
          get :index
          response.body.should_not include(attend_text)
        end
      end
    end
  end

  describe "GET index (json)" do
    before do
      @future_event = create(:event, title: 'FutureBridge', starts_at: 5.days.from_now, ends_at: 6.days.from_now, time_zone: 'Alaska')
      @future_external_event = create(:external_event, name: 'FutureExternalBridge', starts_at: 3.days.from_now, ends_at: 4.days.from_now)
      @past_event = create(:event, title: 'PastBridge', time_zone: 'Alaska')
      @past_event.update_attributes(starts_at: 5.days.ago, ends_at: 4.days.ago)
      @past_external_event = create(:external_event, name: 'PastExternalBridge', starts_at: 3.days.ago, ends_at: 2.days.ago)
      @unpublished_event = create(:event, starts_at: 5.days.from_now, ends_at: 6.days.from_now, published: false)
    end

    it 'can render published past events as json' do
      get :index, format: 'json', type: 'past'
      result_titles = JSON.parse(response.body).map{ |e| e['title'] }
      result_titles.should == [@past_event, @past_external_event].map(&:title)
    end

    it 'can render all published events as json' do
      get :index, format: 'json', type: 'all'
      result_titles = JSON.parse(response.body).map{ |e| e['title'] }
      result_titles.should == [@past_event, @past_external_event, @future_external_event, @future_event].map(&:title)
    end

    it 'can render only upcoming published events as json' do
      get :index, format: 'json', type: 'upcoming'
      result_titles = JSON.parse(response.body).map{ |e| e['title'] }
      result_titles.should == [@future_external_event, @future_event].map(&:title)
    end
  end

  describe "GET show" do
    let!(:event) { create(:event, title: 'DonutBridge') }

    it "successfully assigns the event" do
      get :show, id: event.id
      assigns(:event).should == event
      response.should be_success
    end

    describe "when rendering views" do
      render_views
      before do
        event.location = create(:location, name: 'Carbon Nine')
        event.save!
      end

      it "includes the location" do
        get :show, id: event.id
        response.body.should include('Carbon Nine')
      end

      describe "#allow_student_rsvp?" do
        let(:attend_text) { 'Attend' }
        before do
          sign_in create(:user)
        end

        it "shows an 'Attend' button when allowing student RSVP" do
          event.update_attribute(:allow_student_rsvp, true)
          get :show, id: event.id
          response.body.should include(attend_text)
        end

        it "hides the 'Attend' button when not allowing student RSVP" do
          event.update_attribute(:allow_student_rsvp, false)
          get :show, id: event.id
          response.body.should_not include(attend_text)
        end
      end

      context "when no volunteers or students are attending" do
        it "shows messages about the lack of volunteers and students" do
          get :show, id: event.id
          response.body.should include('No volunteers')
          response.body.should include('No students')
        end
      end

      context "when volunteers are attending" do
        before do
          volunteer = create(:user, first_name: 'Ron', last_name: 'Swanson')
          create(:rsvp, event: event, user: volunteer, role: Role::VOLUNTEER)
        end

        it "shows the volunteer somewhere on the page" do
          get :show, id: event.id
          response.body.should include('Ron Swanson')
        end
      end

      context "when students are attending" do
        before do
          student = create(:user, first_name: 'Jane', last_name: 'Fontaine')
          create(:student_rsvp, event: event, user: student, role: Role::STUDENT)
        end

        it "shows the student somewhere on the page" do
          get :show, id: event.id
          response.body.should include('Jane Fontaine')
        end

        describe 'waitlists' do
          let(:waitlist_label) { 'waitlist' }

          context "when there is no waitlist" do
            it "doesn't have the waitlist header" do
              get :show, id: event.id
              response.body.should_not include(waitlist_label)
            end
          end

          context "when there is a waitlist" do
            before do
              event.update_attribute(:student_rsvp_limit, 1)
              student = create(:user, first_name: 'Sandy', last_name: 'Sontaine')
              create(:student_rsvp, event: event, user: student, role: Role::STUDENT, waitlist_position: 1)
            end

            it "shows waitlisted students in a waitlist section" do
              get :show, id: event.id
              response.body.should include(waitlist_label)
              response.body.should include('Sandy Sontaine')
            end
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
    let!(:event) { create(:event, title: 'DonutBridge') }

    def make_request
      get :edit, :id => event.id
    end

    it_behaves_like "an event action that requires an organizer"

    context "organizer is logged in" do
      before do
        user = create(:user)
        event.organizers << user
        sign_in user
      end

      it "successfully assigns the event" do
        make_request
        assigns(:event).should == event
        response.should be_success
      end
    end
  end

  describe "GET levels" do
    let!(:event) { create(:event, title: 'DonutBridge') }

    it "succeeds without requiring any permissions" do
      get :levels, :id => event.id
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
          next_year = Date.current.year + 1
          {
            "event" => {
              "title" => "Party Zone",
              "target_audience" => "yaya",
              "time_zone" => "Alaska",
              "student_rsvp_limit" => 100,
              "event_sessions_attributes" => {
                "0" => {
                  "name" => 'I am good at naming sessions',
                  "starts_at(1i)" => next_year.to_s,
                  "starts_at(2i)" => "1",
                  "starts_at(3i)" => "12",
                  "starts_at(4i)" => "12",
                  "starts_at(5i)" => "30",
                  "ends_at(1i)" => next_year.to_s,
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

        it "creates a new event with the creator as an organizer" do
          expect {
            make_request(create_params)
          }.to change(Event, :count).by(1)

          Event.last.organizers.should include(@user)
          response.should redirect_to event_path(Event.last)
          flash[:notice].should be_present
        end

        it "sets the event's session times in the event's time zone" do
          make_request(create_params)
          Event.last.event_sessions.last.starts_at.zone.should == 'AKST'
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

          let(:mail) do
            ActionMailer::Base.deliveries.select {|d| d.subject.include? 'awaits approval' }.last
          end
          let(:recipients) { JSON.parse(mail.header['X-SMTPAPI'].to_s)['to'] }

          it "sends an email to all admins/publishers on event creation" do
            expect {
              make_request(create_params)
            }.to change(ActionMailer::Base.deliveries, :count).by(2)

            mail.subject.should include('Nitro Boost')
            mail.subject.should include('Party Zone')
            mail.body.should include('Party Zone')
            mail.body.should include('Nitro Boost')

            recipients.should =~ [@admin.email, @publisher.email]
          end
        end

        describe "notifying the user of pending approval" do
          before do
            @user.update_attributes(first_name: 'Evel', last_name: 'Knievel')
          end

          let(:mail) do
            ActionMailer::Base.deliveries.select {|d| d.subject.include? 'Your Bridge Troll event' }.last
          end
          let(:recipients) { JSON.parse(mail.header['X-SMTPAPI'].to_s)['to'] }

          it "sends an email to the user" do
            expect {
              make_request(create_params)
            }.to change(ActionMailer::Base.deliveries, :count).by(2)

            mail.subject.should include('Party Zone')
            mail.subject.should include('pending approval')
            mail.body.should include('Evel')
            mail.body.should include('event needs to be approved')

            recipients.should =~ [@user.email]
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

  describe "PUT update" do
    let!(:event) { create(:event, title: 'DonutBridge') }

    def make_request(params = {})
      put :update, id: event.id, event: params
    end

    it_behaves_like "an event action that requires an organizer"

    context "organizer is logged in" do
      before do
        user = create(:user)
        event.organizers << user
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

        it "updates the event and redirects to the event page" do
          make_request(update_params)
          event.reload
          event.title.should == "Updated event title"
          event.details.should == "Updated event details"
          response.should redirect_to event_path(event)
          flash[:notice].should be_present
        end

        it "sets the event's session times in the event's time zone" do
          make_request(update_params)
          event_session = event.reload.event_sessions.last
          event_session.starts_at.zone.should == 'VET'
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
          assigns(:event).should == event
          response.should be_unprocessable
          response.should render_template('events/edit')
        end
      end
    end
  end

  describe "DELETE destroy" do
    let!(:event) { create(:event, title: 'DonutBridge') }

    def make_request
      delete :destroy, :id => event.id
    end

    it_behaves_like "an event action that requires an organizer"

    context "organizer is logged in" do
      before do
        user = create(:user)
        event.organizers << user
        sign_in user
      end

      it "destroys the event and redirects to the events page" do
        make_request
        Event.find_by_id(event.id).should == nil
        response.should redirect_to events_path
      end
    end
  end

  describe "GET feed" do
    let!(:event) { create(:event, title: 'DonutBridge') }
    let!(:other_event) { create(:event, title: 'C5 Event!') }
    render_views

    context "when format is RSS" do
      before do
        get :feed, format: :rss
      end

      it "successfully directs to xml rss feed" do
        response.should be_success

        event.should be_in(assigns(:events))
        other_event.should be_in(assigns(:events))
      end

      it "has rss formatting" do
        response.body.should include 'rss'
      end

      it "includes the website title" do
        response.body.should include ('RailsBridge')
      end

      it "includes all events" do
        response.body.should include ('DonutBridge')
        response.body.should include ('C5 Event!')
      end
    end

    context "when format is Atom" do
      before do
        get :feed, format: :atom
      end

      it "successfully directs to xml rss feed" do
        response.should be_success

        event.should be_in(assigns(:events))
        other_event.should be_in(assigns(:events))
      end

      it "has rss formatting" do
        response.body.should include 'feed'
      end

      it "includes the website title" do
        response.body.should include ('RailsBridge')
      end

      it "includes all events" do
        response.body.should include ('DonutBridge')
        response.body.should include ('C5 Event!')
      end
    end
  end
end
