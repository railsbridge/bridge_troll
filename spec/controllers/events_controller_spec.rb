require 'spec_helper'

describe EventsController do
  before do
    @event = create(:event)
  end

  describe "GET index" do
    it "succeeds" do
      get :index
      response.should be_success
    end

    it "assigns upcoming events" do
      get :index
      assigns(:events).should == [@event]
    end
  end

  describe "GET show" do
    it "succeeds" do
      get :show, id: @event.id
      response.should be_success
    end

    it "assigns the event" do
      get :show, id: @event.id
      assigns(:event).should == @event
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
            response.body.should_not include('Waitlist')
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
            response.body.should include('Waitlist')
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

      it "succeeds" do
        get :new
        response.should be_success
      end

      it "assigns an event" do
        get :new
        assigns(:event).should be_new_record
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

      it "succeeds" do
        make_request
        response.should be_success
      end

      it "assigns the event" do
        make_request
        assigns(:event).should == @event
      end
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
              "title" => "asdfasdfasdf",
              "time_zone" => "Alaska",
              "student_rsvp_limit" => 100,
              "event_sessions_attributes" => {
                "0" => {
                  "name" => 'I am good at naming sessions',
                  "starts_at(1i)" => "2013",
                  "starts_at(2i)" => "1",
                  "starts_at(3i)" => "12",
                  "starts_at(4i)" => "12",
                  "starts_at(5i)" => "30",
                  "ends_at(1i)" => "2013",
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
          flash[:notice].should_not be_empty
        end
      end

      describe "with invalid params" do
        it "does not create an event" do
          expect { make_request }.to_not change { Event.count }
        end

        it "assigns the event" do
          make_request
          assigns(:event).should be_new_record
        end

        it "renders the new page" do
          make_request
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
          @session1 = @event.event_sessions.first
          @session2 = create(:event_session, event: @event)

          attendee1 = create(:user)
          rsvp1 = create(:rsvp, event: @event, user: attendee1, role: Role::VOLUNTEER)
          create(:rsvp_session, rsvp: rsvp1, event_session: @session1, checked_in: true)
          create(:rsvp_session, rsvp: rsvp1, event_session: @session2, checked_in: true)

          attendee2 = create(:user)
          rsvp2 = create(:rsvp, event: @event, user: attendee2, role: Role::VOLUNTEER)
          create(:rsvp_session, rsvp: rsvp2, event_session: @session1, checked_in: true)
          create(:rsvp_session, rsvp: rsvp2, event_session: @session2, checked_in: false)

          attendee3 = create(:user)
          rsvp3 = create(:rsvp, event: @event, user: attendee3, role: Role::VOLUNTEER)
          create(:rsvp_session, rsvp: rsvp3, event_session: @session1, checked_in: true)
        end

        it "sends checked in user counts to the view" do
          make_request
          assigns(:session_rsvp_counts).should == {
            @session1.id => 3,
            @session2.id => 2
          }
          assigns(:session_checkin_counts).should == {
            @session1.id => 3,
            @session2.id => 1
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
          flash[:notice].should_not be_empty
        end
      end

      describe "with invalid params" do
        let(:invalid_params) {
          {
            "title" => ""
          }
        }

        it "assigns the event" do
          make_request(invalid_params)
          assigns(:event).should == @event
        end

        it "renders the edit form" do
          make_request(invalid_params)
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
        Event.find_by_id(@event.id).should == nil
      end

      it "redirects to the events page" do
        make_request
        response.should redirect_to events_path
      end
    end
  end
end
