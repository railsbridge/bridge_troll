require 'rails_helper'

describe Events::UnpublishedEventsController do
  before do
    @event = create(:event, title: 'DonutBridge')
  end

  describe "GET #index" do
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
      get :index

      assigns(:chapter_user_counts).should == {
        @chapter1.id => 2,
        @chapter2.id => 2
      }
    end
  end

  describe "POST #publish" do
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
        post :publish, unpublished_event_id: @event.id
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
        post :publish, unpublished_event_id: @event.id
      }.not_to change(ActionMailer::Base.deliveries, :count)
      @event.reload.should be_published
    end
  end
end