require 'rails_helper'

describe EventsController do
  describe "GET index" do
    let!(:event) { create(:event, title: 'DonutBridge') }

    it "successfully assigns upcoming events" do
      get :index
      expect(response).to be_success
      expect(assigns(:events)).to eq([event])
    end

    describe "when rendering views" do
      render_views

      describe "#allow_student_rsvp?" do
        let(:attend_text) { 'Attend' }

        it "shows an 'Attend' button when allowing student RSVP" do
          event.update_attribute(:allow_student_rsvp, true)
          get :index
          expect(response.body).to include(attend_text)
        end

        it "hides the 'Attend' button when not allowing student RSVP" do
          event.update_attribute(:allow_student_rsvp, false)
          get :index
          expect(response.body).not_to include(attend_text)
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
      @unpublished_event = create(:event, starts_at: 5.days.from_now, ends_at: 6.days.from_now, current_state: :pending_approval)
    end

    it 'can render published past events as json' do
      get :index, format: 'json', type: 'past'
      result_titles = JSON.parse(response.body).map{ |e| e['title'] }
      expect(result_titles).to eq([@past_event, @past_external_event].map(&:title))
    end

    it 'can render all published events as json' do
      get :index, format: 'json', type: 'all'
      result_titles = JSON.parse(response.body).map{ |e| e['title'] }
      expect(result_titles).to eq([@past_event, @past_external_event, @future_external_event, @future_event].map(&:title))
    end

    it 'can render only upcoming published events as json' do
      get :index, format: 'json', type: 'upcoming'
      result_titles = JSON.parse(response.body).map{ |e| e['title'] }
      expect(result_titles).to eq([@future_external_event, @future_event].map(&:title))
    end
  end

  describe "GET show" do
    let!(:event) { create(:event, title: 'DonutBridge') }

    it "successfully assigns the event" do
      get :show, id: event.id
      expect(assigns(:event)).to eq(event)
      expect(response).to be_success
    end

    describe "when rendering views" do
      render_views
      before do
        event.location = create(:location, name: 'Carbon Nine')
        event.save!
      end

      it "includes the location" do
        get :show, id: event.id
        expect(response.body).to include('Carbon Nine')
      end

      describe "authorization message" do
        it "can tell the user they are a chapter leader" do
          chapter_leader = create(:user)
          chapter_leader.chapter_leaderships.create(chapter: event.chapter)

          sign_in chapter_leader

          get :show, id: event.id
          expect(response.body).to include('As a chapter leader')
        end

        it "can tell the user they are an organization leader" do
          organization_leader = create(:user)
          organization_leader.organization_leaderships.create(organization: event.organization)

          sign_in organization_leader

          get :show, id: event.id
          expect(response.body).to include('As an organization leader')
        end
      end

      describe "#allow_student_rsvp?" do
        let(:attend_text) { 'Attend' }
        before do
          sign_in create(:user)
        end

        it "shows an 'Attend' button when allowing student RSVP" do
          event.update_attribute(:allow_student_rsvp, true)
          get :show, id: event.id
          expect(response.body).to include(attend_text)
        end

        it "hides the 'Attend' button when not allowing student RSVP" do
          event.update_attribute(:allow_student_rsvp, false)
          get :show, id: event.id
          expect(response.body).not_to include(attend_text)
        end
      end

      context "when no volunteers or students are attending" do
        it "shows messages about the lack of volunteers and students" do
          get :show, id: event.id
          expect(response.body).to include('No volunteers')
          expect(response.body).to include('No students')
        end
      end

      context "when volunteers are attending" do
        before do
          volunteer = create(:user, first_name: 'Ron', last_name: 'Swanson')
          create(:rsvp, event: event, user: volunteer, role: Role::VOLUNTEER)
        end

        it "shows the volunteer somewhere on the page" do
          get :show, id: event.id
          expect(response.body).to include('Ron Swanson')
        end
      end

      context "when students are attending" do
        before do
          student = create(:user, first_name: 'Jane', last_name: 'Fontaine')
          create(:student_rsvp, event: event, user: student, role: Role::STUDENT)
        end

        it "shows the student somewhere on the page" do
          get :show, id: event.id
          expect(response.body).to include('Jane Fontaine')
        end

        describe 'waitlists' do
          let(:waitlist_label) { 'waitlist' }

          context "when there is no waitlist" do
            it "doesn't have the waitlist header" do
              get :show, id: event.id
              expect(response.body).not_to include(waitlist_label)
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
              expect(response.body).to include(waitlist_label)
              expect(response.body).to include('Sandy Sontaine')
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
        expect(assigns(:event)).to be_new_record
        expect(response).to be_success
      end

      it "uses the logged in user's time zone as the event's time zone" do
        get :new
        expect(assigns(:event).time_zone).to eq('Alaska')
      end

      it "assigns an empty location" do
        get :new
        expect(assigns(:location)).to be_new_record
        expect(response).to be_success
      end
    end
  end

  describe "GET edit" do
    let!(:event) { create(:event, title: 'DonutBridge') }

    def make_request
      get :edit, id: event.id
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
        expect(assigns(:event)).to eq(event)
        expect(response).to be_success
      end
    end
  end

  describe "GET levels" do
    let!(:event) { create(:event, title: 'DonutBridge') }

    it "succeeds without requiring any permissions" do
      get :levels, id: event.id
      expect(response).to be_success
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
        let!(:chapter) { create(:chapter) }
        let!(:location) { create(:location) }
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
              "location_id" => location.id,
              "chapter_id" => chapter.id,
              "details" => "sdfasdfasdf"
            }
          }
        }

        it "creates a new event with the creator as an organizer" do
          expect {
            make_request(create_params)
          }.to change(Event, :count).by(1)

          expect(Event.last.organizers).to include(@user)
          expect(response).to redirect_to event_path(Event.last)
          expect(flash[:notice]).to be_present
        end

        it "sets the event's session times in the event's time zone" do
          make_request(create_params)
          expect(Event.last.event_sessions.last.starts_at.zone).to eq('AKST')
        end

        context "but the user is flagged as a spammer" do
          before do
            @user.update_attribute(:spammer, true)
          end

          it "sends no email and flags the event as spam after creation" do
            expect {
              make_request(create_params)
            }.not_to change(ActionMailer::Base.deliveries, :count)
            expect(Event.last).to be_spam
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

          it "sends an email to all admins/publishers on event creation" do
            expect {
              make_request(create_params)
            }.to change(ActionMailer::Base.deliveries, :count).by(2)

            expect(mail.subject).to include('Nitro Boost')
            expect(mail.subject).to include('Party Zone')
            expect(mail.body).to include('Party Zone')
            expect(mail.body).to include('Nitro Boost')

            expect(mail.to).to match_array([@admin.email, @publisher.email])
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

            expect(mail.subject).to include('Party Zone')
            expect(mail.subject).to include('pending approval')
            expect(mail.body).to include('Evel')
            expect(mail.body).to include('event needs to be approved')

            expect(recipients).to match_array([@user.email])
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

          expect(assigns(:event)).to be_new_record
          expect(response).to be_success
          expect(response).to render_template('events/new')
        end
      end
    end
  end

  describe "PUT update" do
    let!(:event) { create(:event, title: 'DonutBridge') }

    def make_request(params = {})
      put :update, id: event.id, event: params, create_event: true
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
          expect(event.title).to eq("Updated event title")
          expect(event.details).to eq("Updated event details")
          expect(response).to redirect_to event_path(event)
          expect(flash[:notice]).to be_present
        end

        describe "when the event has been published" do
          before do
            event.update_attribute(:current_state, :published)
          end

          it "updates attributes while keeping the event in published state" do
            make_request(update_params)
            expect(event.reload.current_state).to eq('published')
          end
        end

        it "sets the event's session times in the event's time zone" do
          make_request(update_params)
          event_session = event.reload.event_sessions.last
          expect(event_session.starts_at.zone).to eq('VET')
        end

        context 'when the event was previously in a draft state' do
          before do
            event.update_attributes(current_state: :draft)
          end

          it "sends an approval email to all admins/publishers on event creation" do
            expect {
              make_request(update_params)
            }.to change(ActionMailer::Base.deliveries, :count).by(2)

            approval_mail = ActionMailer::Base.deliveries.select {|d| d.subject.include? 'awaits approval' }.last
            expect(approval_mail).to be
          end
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
          expect(assigns(:event)).to eq(event)
          expect(response).to be_unprocessable
          expect(response).to render_template('events/edit')
        end
      end
    end
  end

  describe "DELETE destroy" do
    let!(:event) { create(:event, title: 'DonutBridge') }

    def make_request
      delete :destroy, id: event.id
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
        expect(Event.find_by_id(event.id)).to eq(nil)
        expect(response).to redirect_to events_path
      end
    end
  end

  describe "GET feed" do
    render_views
    let(:rss_item_tag) { 'item' }
    let(:atom_item_tag) { 'entry' }

    context 'when there are no events' do
      it 'returns an empty feed' do
        get :feed, format: :rss
        expect(response.body).to include 'rss'
        expect(Nokogiri::XML.parse(response.body).css(rss_item_tag).length).to eq(0)

        get :feed, format: :atom
        expect(response.body).to include 'atom'
        expect(Nokogiri::XML.parse(response.body).css(atom_item_tag).to_a.length).to eq(0)
      end
    end

    context "when format is RSS" do
      let!(:event) { create(:event, title: 'DonutBridge') }
      let!(:other_event) { create(:event, title: 'C5 Event!') }
      let(:item_tag) { rss_item_tag }

      before do
        get :feed, format: :rss
      end

      it "successfully directs to xml rss feed" do
        expect(response).to be_success

        expect(event).to be_in(assigns(:events))
        expect(other_event).to be_in(assigns(:events))
      end

      it "has rss formatting" do
        expect(response.body).to include 'rss'
      end

      it "includes the website title" do
        expect(response.body).to include('Bridge Troll Events')
      end

      it "includes all events" do
        expect(Nokogiri::XML.parse(response.body).css(item_tag).length).to eq(2)
        expect(response.body).to include('DonutBridge')
        expect(response.body).to include('C5 Event!')
      end
    end

    context "when format is Atom" do
      let!(:event) { create(:event, title: 'DonutBridge') }
      let!(:other_event) { create(:event, title: 'C5 Event!') }
      let(:item_tag) { atom_item_tag }

      before do
        get :feed, format: :atom
      end

      it "successfully directs to xml rss feed" do
        expect(response).to be_success

        expect(event).to be_in(assigns(:events))
        expect(other_event).to be_in(assigns(:events))
      end

      it "has atom formatting" do
        expect(response.body).to include 'feed'
      end

      it "includes the website title" do
        expect(response.body).to include('Bridge Troll Events')
      end

      it "includes all events" do
        expect(Nokogiri::XML.parse(response.body).css(item_tag).length).to eq(2)
        expect(response.body).to include('DonutBridge')
        expect(response.body).to include('C5 Event!')
      end
    end
  end
end
