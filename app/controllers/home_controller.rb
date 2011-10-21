class HomeController < ApplicationController
  def index
    if return_to = session[:return_to]
      session[:return_to] = nil
      redirect_to return_to
    end
    @upcoming = Event.upcoming
    @past = Event.past
  end
end
