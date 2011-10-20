class HomeController < ApplicationController
  def index
    @upcoming = Event.all
  end
end
