# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    skip_authorization
    respond_to do |format|
      format.html {}
      format.json do
        render json: UserList.new(params)
      end
    end
  end
end
