require 'rails_helper'

describe Events::UnpublishedEventsController do
  before do
    @event = create(:event, title: 'DonutBridge')
  end

  describe "GET #index" do
    before do
      sign_in create(:user, publisher: true)
    end

    it 'displays events that are publishable' do
      published_event = create(:event, published: true, draft_saved: false)
      draft_event = create(:event, published: false, draft_saved: true)
      pending_approval_event = create(:event, published: false, draft_saved: false)

      get :index

      expect(assigns(:events)).to match_array([pending_approval_event])
    end

    describe 'chapter user counts' do
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
      end

      it "assigns a hash of chapter/user counts" do
        get :index

        expect(assigns(:chapter_user_counts)).to eq({
          @chapter1.id => 2,
          @chapter2.id => 2
        })
      end
    end
  end

  describe "POST #publish" do
    def make_request
      post :publish, unpublished_event_id: @event.id
    end

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

    it 'publishes the event' do
      make_request
      expect(@event.reload).to be_published
    end

    it 'mails every user that is associated with this chapter' do
      expect { make_request }.to change(ActionMailer::Base.deliveries, :count).by(1)

      expect(recipients).to match_array([@user_this_chapter.email, @user_both_chapters.email])

      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to include(@event.chapter.name)
      expect(mail.body).to include(@event.title)
    end

    context 'if the announcement emails should be sent manually' do
      before do
        @event.update_attribute(:email_on_approval, false)
      end

      it 'sends no emails' do
        expect { make_request }.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end

    it 'updates the time the announcement email was sent' do
      @event.update_attribute(:email_on_approval, true)
      expect {
        make_request
      }.to change{ @event.reload.announcement_email_sent_at.present? }.from(false).to(true)
    end
  end
end