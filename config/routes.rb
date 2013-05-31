Bridgetroll::Application.routes.draw do
  root :to => "events#index"

  devise_for :users

  resources :users, only: [:index] do
    resource :profile, :only => [:edit, :update, :show]
    resource :meetup_prompt, :only => [:destroy], :controller => 'users/meetup_prompts'
  end
  resources :meetup_users, :only => [:show]

  resources :locations

  resources :events do
    resources :organizers, :only => [:index, :create, :destroy]
    resources :volunteers, :only => [:index, :update]
    resources :students, :only => [:index], :controller => 'events/students'
    resources :attendees, :only => [:index], :controller => 'events/attendees'

    resources :rsvps, :except => [:index, :new] do
      new do
        get :volunteer
        get :learn
      end
    end

    resources :event_sessions, :only => [] do
      resources :checkins, :only => [:index, :create, :destroy]
    end
    get "volunteer_emails" => "events#volunteer_emails", :on => :member
    get "organize", :on => :member
    get "organize_sections", :on => :member
  end

  get "/auth/:provider/callback" => "omniauths#callback"

  if Rails.env.development?
    get "/style_guide" => "static_pages#style_guide"
  end
end
