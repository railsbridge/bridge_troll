Bridgetroll::Application.routes.draw do
  root to: "events#index"

  devise_for :users, controllers: {registrations: "devise_overrides/registrations"}

  resources :users, only: [:index] do
    resource :profile, :only => [:edit, :update, :show]
    resource :meetup_prompt, :only => [:destroy], :controller => 'users/meetup_prompts'
  end
  resources :meetup_users, :only => [:show]

  resources :locations

  resources :events do
    resources :organizers, :only => [:index, :create, :destroy]
    resources :checkiners, :only => [:index, :create, :destroy]
    resources :volunteers, :only => [:index, :update]

    resources :students, :only => [:index], :controller => 'events/students'
    resources :attendees, :only => [:index, :update], :controller => 'events/attendees'
    resources :emails, :only => [:new, :create, :show], :controller => 'events/emails'

    resources :sections, :only => [:create, :update, :destroy] do
      post :arrange, on: :collection
    end

    resources :rsvps, :except => [:index, :new] do
      new do
        get :volunteer
        get :learn
      end
    end

    resources :event_sessions, :only => [:index] do
      resources :checkins, :only => [:index, :create, :destroy]
    end

    member do
      get "organize"
      get "organize_sections"
      get "levels"
      get "diets"
    end
  end

  resources :external_events

  get "/past_events" => "events#past_events"

  get "/about" => "static_pages#about"

  get "/auth/:provider/callback" => "omniauths#callback"

  if Rails.env.development?
    get "/style_guide" => "static_pages#style_guide"
  end
end
