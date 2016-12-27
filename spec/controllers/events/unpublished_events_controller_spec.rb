require 'rails_helper'

describe Events::UnpublishedEventsController do
  before do
    @event = create(:event, title: 'DonutBridge')
    @organizer = create(:user)
    @event.organizers << @organizer
  end

  describe "GET #index" do
    describe "visibility" do
      let!(:chapter) { create(:chapter) }
      let!(:pending_chapter_event) { create(:event, chapter: chapter, current_state: :pending_approval) }
      let!(:pending_other_event) { create(:event, current_state: :pending_approval) }
      let!(:draft_event) { create(:event, current_state: :draft) }
      let!(:published_event) { create(:event, current_state: :published) }

      context "as an admin/publisher" do
        before do
          sign_in create(:user, publisher: true)
        end

        it 'displays all events that are publishable' do
          get :index

          expect(assigns(:events)).to match_array([pending_chapter_event, pending_other_event])
        end
      end

      context "as a chapter leader" do
        before do
          leader = create(:user)
          chapter.leaders << leader
          sign_in leader
        end

        it 'displays events that are publishable for that chapter' do
          get :index

          expect(assigns(:events)).to match_array([pending_chapter_event])
        end
      end
    end
  end

  describe "POST #publish" do
    def make_request
      post :publish, unpublished_event_id: @event.id
    end

    before do
      this_region = @event.region
      this_region.update_attributes(name: 'RailsBridge Shellmound')
      other_region = create(:region, name: 'RailsBridge Meriloft')

      @user_none = create(:user)

      @user_this_region = create(:user)
      @user_this_region.regions << this_region

      @user_no_email = create(:user, allow_event_email: false)
      @user_no_email.regions << this_region
      @event.organizers << @user_no_email

      @user_other_region = create(:user)
      @user_other_region.regions << other_region

      @user_both_regions = create(:user)
      @user_both_regions.regions << this_region
      @user_both_regions.regions << other_region

      sign_in create(:user, publisher: true)
    end

    def recipients(mail)
      JSON.parse(mail.header['X-SMTPAPI'].to_s)['to']
    end

    it 'publishes the event' do
      make_request
      expect(@event.reload).to be_published
    end

    it 'mails every user that is associated with this region' do
      expect { make_request }.to change(ActionMailer::Base.deliveries, :count).by_at_least(1)

      mail = ActionMailer::Base.deliveries.find { |m| m.subject.match('New event posted') }

      expect(recipients(mail)).to match_array([@user_this_region.email, @user_both_regions.email])

      expect(mail.subject).to include(@event.region.name)
      expect(mail.body).to include(@event.title)
    end

    context 'if the announcement emails should be sent manually' do
      before do
        @event.update_attribute(:email_on_approval, false)
      end

      it 'lets the organizer know their event has been approved and does not send announcement emails' do
        expect { make_request }.to change(ActionMailer::Base.deliveries, :count).by_at_least(1)

        mail = ActionMailer::Base.deliveries.find { |m| m.subject.match('has been approved') }

        expect(recipients(mail)).to match_array([@organizer.email, @user_no_email.email])

        expect(mail.subject).to include("Your Bridge Troll event has been approved")
        expect(mail.body).to include(@event.title)
        expect(mail.subject).not_to include("New event posted:")
      end
    end

    it 'updates the time the announcement email was sent' do
      @event.update_attribute(:email_on_approval, true)
      expect {
        make_request
      }.to change{ @event.reload.announcement_email_sent_at.present? }.from(false).to(true)
    end

    context 'as a chapter leader' do
      before do
        chapter = create(:chapter)
        leader = create(:user)
        chapter.leaders << leader
        @chapter_event = create(:event, chapter: chapter, current_state: :pending_approval)
        @chapter_event.organizers << @organizer
        sign_in leader
      end

      it 'allows publishing of chapter events' do
        expect {
          post :publish, unpublished_event_id: @chapter_event.id
        }.to change { @chapter_event.reload.current_state }.to('published')
      end

      it 'disallows publishing of non-chapter events' do
        expect {
          post :publish, unpublished_event_id: @event.id
        }.not_to change { @chapter_event.reload.current_state }
        expect(response).to be_redirect
      end
    end
  end
end
