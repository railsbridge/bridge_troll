class SkillsController < Devise::RegistrationsController
  def new
    super
  end
  
  def edit
    @user = current_user
  end
end
