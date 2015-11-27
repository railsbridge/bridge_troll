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
      published_event = create(:event, current_state: :published)
      draft_event = create(:event, current_state: :draft)
      pending_approval_event = create(:event, current_state: :pending_approval)

      get :index

      expect(assigns(:events)).to match_array([pending_approval_event])
    end

    describe 'region user counts' do
      before do
        @region1 = @event.region
        @region1.update_attributes(name: 'RailsBridge Shellmound')
        @region2 = create(:region, name: 'RailsBridge Meriloft')

        user_none = create(:user)

        user_region1 = create(:user)
        user_region1.regions << @region1

        user_region2 = create(:user)
        user_region2.regions << @region2

        user_both_regions = create(:user)
        user_both_regions.regions << @region1
        user_both_regions.regions << @region2

        user_no_email = create(:user, allow_event_email: false)
        user_no_email.regions << @region1
      end

      it "assigns a hash of region/user counts" do
        get :index

        expect(assigns(:region_user_counts)).to eq({
          @region1.id => 2,
          @region2.id => 2
        })
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

      @user_other_region = create(:user)
      @user_other_region.regions << other_region

      @user_both_regions = create(:user)
      @user_both_regions.regions << this_region
      @user_both_regions.regions << other_region

      sign_in create(:user, publisher: true)
    end

    let(:recipients) { JSON.parse(ActionMailer::Base.deliveries.last.header['X-SMTPAPI'].to_s)['to'] }

    it 'publishes the event' do
      make_request
      expect(@event.reload).to be_published
    end

    it 'mails every user that is associated with this region' do
      expect { make_request }.to change(ActionMailer::Base.deliveries, :count).by(1)

      expect(recipients).to match_array([@user_this_region.email, @user_both_regions.email])

      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to include(@event.region.name)
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