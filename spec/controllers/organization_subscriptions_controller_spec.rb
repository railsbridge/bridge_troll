require 'rails_helper'

describe OrganizationSubscriptionsController do
  before { @authorization_token = 'andyandhaseebaregarbageteacherss' }


  describe '#edit' do
    subject { get :edit, token: @authorization_token }

    context 'a user exists with the specified email_authorization_token' do
      before do
        @user = create(:user,
          email_authentication_token: @authorization_token,
          email_authentication_created_at: Time.now)
      end

      it 'renders the edit form' do
        expect(subject).to render_template(:edit)
      end

      context 'the token was generated more than 2 weeks ago' do
        before { @user.update! email_authentication_created_at: 3.weeks.ago }

        it 'redirects to the root' do
          expect(subject).to redirect_to(root_url)
          expect(flash[:notice]).to match('link has expired.')
        end
      end
    end

    context 'a user does not exist with the specified email_authorization_token' do
      it 'redirects to the root' do
        expect(subject).to redirect_to(root_url)
      end
    end
  end

  describe '#update' do
    subject do
      put :update,
        token: @authorization_token,
        user: {
          subscribed_organization_ids: @subscribed_organizations
        }
    end

    context 'a user exists with the token' do
      before do
        @user = create(:user,
          email_authentication_token: @authorization_token,
          email_authentication_created_at: Time.now)

        3.times do
          create(:organization)
        end

        @subscribed_organizations = Organization.all.pluck(:id).drop(1)
      end

      it 'updates the email preferences of the user, without logging in' do
        subject
        expect(@user.subscribed_organizations)
          .to match_array Organization.where(id: @subscribed_organizations)
        expect(flash[:notice]).to match(/thanks/i)
        expect(controller.current_user).to be_nil
      end

      context 'the token was generated more than 2 weeks ago' do
        before { @user.update! email_authentication_created_at: 3.weeks.ago }

        it 'redirects to the root' do
          expect {
            expect(subject).to redirect_to(root_url)
          }.not_to change { @user.reload.subscribed_organizations }
        end
      end
    end

    context 'a user does not exist with the token' do
      it 'redirects to the root' do
        expect(subject).to redirect_to(root_url)
      end
    end
  end
end
