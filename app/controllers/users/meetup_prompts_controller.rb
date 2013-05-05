module Users
  class MeetupPromptsController < ApplicationController
    def destroy
      @meetup_prompt = MeetupPrompt.build(current_user)
      @meetup_prompt.destroy if @meetup_prompt
      head :ok
    end
  end
end