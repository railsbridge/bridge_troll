require 'spec_helper'

describe RsvpsController do
  def extract_rsvp_params(rsvp)
    rsvp.attributes.except *%w{user_id id created_at updated_at}
  end

  before do
    @event = create(:event, title: 'The Best Railsbridge')
  end

  describe "#create" do
    before do
      @rsvp_params = extract_rsvp_params build(:rsvp, :event => @event)
    end
    context "without logging in, I am redirected from the page" do
      it "redirects to the sign in page" do
        assigns[:current_user].should be_nil
        post :create, { :rsvp => @rsvp_params }
        response.should redirect_to("/users/sign_in")
      end

      it "does not create any new rsvps" do
        expect {
        post :create, { :rsvp => @rsvp_params }
        }.to_not change { Rsvp.count }
      end
    end

    context "when there is no rsvp for the volunteer/event" do
      before do
        @user = create(:user)
        sign_in @user
        @rsvp_params = extract_rsvp_params build(:rsvp, :event => @event)
      end

      context "as a logged in user I should be able to volunteer for an event" do
        it "should allow the user to newly volunteer for an event" do
          expect {
          post :create, { :rsvp => @rsvp_params }
          }.to change {Rsvp.count }.by(1)
        end

        it "redirects to the event page related to the rsvp with flash confirmation" do
          post :create, { :rsvp => @rsvp_params }
          response.should redirect_to(event_path(@event))
          flash[:notice].should match(/thanks/i)
        end

        it "should create a rsvp that persists and is valid" do
          post :create, { :rsvp => @rsvp_params }
          assigns[:rsvp].should be_persisted
          assigns[:rsvp].should be_valid
        end

        it "should set the new rsvp with the selected event, and current user" do
          post :create, { :rsvp => @rsvp_params }
          assigns[:rsvp].user_id.should == assigns[:current_user].id
          assigns[:rsvp].event_id.should == @event.id
        end
      end
    end

    context "when there is already a rsvp for the volunteer/event" do
      #the user may have canceled, changed his/her mind, and decided to volunteer again
      before do
        @user = create(:user)
        sign_in @user
        @rsvp = create(:rsvp, user: @user, event: @event)
        @rsvp_params = extract_rsvp_params @rsvp
      end

      it "does not create any new rsvps" do
        expect {
          post :create, { :rsvp => @rsvp_params }
        }.to_not change { Rsvp.count }
      end
    end
  end
  
  describe "#destroy" do
    before do
      @user = create(:user)
      sign_in @user
    end

    context "the user has signed up to volunteer and changed his/her mind" do
      before do
        @rsvp = create(:rsvp)
      end
      it "should destroy the rsvp" do
        expect {
          delete :destroy, { :id => @rsvp.id }
        }.to change {Rsvp.count }.by(-1)
        expect {
          @rsvp.reload
        }.to raise_error(ActiveRecord::RecordNotFound)
        flash[:notice].should match(/no longer signed up to volunteer/i)
      end
    end

    context "there is no rsvp record for this user at this event" do
      it "should notify the user s/he has not signed up to volunteer for the event" do
        expect {
          delete :destroy, { :id => 29101 }
        }.to change {Rsvp.count }.by(0)
        flash[:notice].should match(/You are not signed up to volunteer/i)
      end
    end
  end
end
