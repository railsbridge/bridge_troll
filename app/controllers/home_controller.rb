class HomeController < ApplicationController
  def index
    @upcoming = Event.upcoming
    @past = Event.past
  end
end
