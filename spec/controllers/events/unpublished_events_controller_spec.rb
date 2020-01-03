# frozen_string_literal: true

require 'rails_helper'

describe Events::UnpublishedEventsController do
  let(:event) { create(:event, title: 'DonutBridge') }
  let(:organizer) { create(:user) }

  before do
    event.organizers << organizer
  end

  describe 'GET #index' do
    describe 'visibility' do
      let!(:chapter) { create(:chapter) }
      let!(:pending_chapter_event) { create(:event, chapter: chapter, current_state: :pending_approval) }
      let!(:pending_other_event) { create(:event, current_state: :pending_approval) }

      before do
        create(:event, current_state: :draft)
        create(:event, current_state: :published)
      end

      context 'as an admin/publisher' do
        before do
          sign_in create(:user, publisher: true)
        end

        it 'displays all events that are publishable' do
          get :index

          expect(assigns(:events)).to match_array([pending_chapter_event, pending_other_event])
        end
      end

      context 'as a chapter leader' do
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

  describe 'POST #publish' do
    def make_request
      post :publish, params: { unpublished_event_id: event.id }
    end

    let!(:user_this_region) do
      create(:user).tap { |u| u.regions << this_region }
    end

    let!(:this_region) { event.region.tap { |r| r.update(name: 'RailsBridge Shellmound') } }

    let!(:user_both_regions) do
      create(:user).tap do |u|
        u.regions << this_region
        u.regions << other_region
      end
    end
    let!(:other_region) { create(:region, name: 'RailsBridge Meriloft') }
    let!(:user_no_email) do
      create(:user, allow_event_email: false).tap do |u|
        u.regions << this_region
      end
    end

    before do
      create(:user) # non-affiliated user
      event.organizers << user_no_email

      user_other_region = create(:user)
      user_other_region.regions << other_region

      sign_in create(:user, publisher: true)
    end

    def recipients(mail)
      JSON.parse(mail.header['X-SMTPAPI'].to_s)['to']
    end

    it 'publishes the event' do
      make_request
      expect(event.reload).to be_published
    end

    it 'mails every user that is associated with this region' do
      expect { make_request }.to change(ActionMailer::Base.deliveries, :count).by_at_least(1)

      mail = ActionMailer::Base.deliveries.find { |m| m.subject.match('New event posted') }

      expect(recipients(mail)).to match_array([user_this_region.email, user_both_regions.email])

      expect(mail.subject).to include(event.region.name)
      expect(mail.body).to include(event.title)
    end

    context 'if the announcement emails should be sent manually' do
      before do
        event.update_attribute(:email_on_approval, false)
      end

      it 'lets the organizer know their event has been approved and does not send announcement emails' do
        expect { make_request }.to change(ActionMailer::Base.deliveries, :count).by_at_least(1)

        mail = ActionMailer::Base.deliveries.find { |m| m.subject.match('has been approved') }

        expect(recipients(mail)).to match_array([organizer.email, user_no_email.email])

        expect(mail.subject).to include('Your Bridge Troll event has been approved')
        expect(mail.body).to include(event.title)
        expect(mail.subject).not_to include('New event posted:')
      end
    end

    it 'updates the time the announcement email was sent' do
      event.update_attribute(:email_on_approval, true)
      expect do
        make_request
      end.to change { event.reload.announcement_email_sent_at.present? }.from(false).to(true)
    end

    context 'as a chapter leader' do
      let(:chapter) { create(:chapter) }
      let(:chapter_event) do
        create(:event, chapter: chapter, current_state: :pending_approval).tap do |e|
          e.organizers << organizer
        end
      end

      before do
        leader = create(:user)
        chapter.leaders << leader
        sign_in leader
      end

      it 'allows publishing of chapter events' do
        expect do
          post :publish, params: { unpublished_event_id: chapter_event.id }
        end.to change { chapter_event.reload.current_state }.to('published')
      end

      it 'disallows publishing of non-chapter events' do
        expect do
          post :publish, params: { unpublished_event_id: event.id }
        end.not_to(change { chapter_event.reload.current_state })
        expect(response).to be_redirect
      end
    end
  end
end
