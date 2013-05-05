class MeetupPrompt
  def self.build(user)
    return if !user || user.meetup_id || user.meetup_prompt_dismissed

    new(user)
  end

  def initialize(user)
    @user = user
  end

  def path
    "/users/#{@user.id}/meetup_prompt"
  end

  def destroy
    @user.meetup_prompt_dismissed = true
    @user.save
  end
end