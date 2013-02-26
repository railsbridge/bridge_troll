Bridgetroll::Application.routes.draw do
  root :to => "events#index"

  devise_for :users

  resources :users do
    resource :profile, :only => [:edit, :update, :show]
  end
  resources :meetup_users, :only => [:index, :show]

  resources :locations

  resources :events do
    resources :organizers, :only => [:index, :create, :destroy]
    resources :volunteers, :only => [:index, :update]
    resources :rsvps, :except => :index
    resources :event_sessions, :only => [] do
      resources :checkins, :only => [:index, :create, :destroy]
    end
  end
end
