Bridgetroll::Application.routes.draw do
  root to: "events#index"

  devise_for :users, controllers: {
    registrations: "devise_overrides/registrations",
    omniauth_callbacks: "devise_overrides/omniauth_callbacks"
  }

  resources :users, only: [:index] do
    resource :profile, only: [:show]
    resources :events, only: [:index], controller: 'users/events'
  end
  resources :meetup_users, only: [:show]

  resources :locations
  resources :chapters
  resources :regions do
    resources :region_leaderships, only: [:index, :create, :destroy]
  end

  resources :events do
    resources :organizers, only: [:index, :create, :destroy] do
      get :potential, on: :collection
    end
    resources :checkiners, only: [:index, :create, :destroy]
    resources :volunteers, only: [:index]

    resources :students, only: [:index], controller: 'events/students'
    resources :attendees, only: [:index, :update], controller: 'events/attendees'
    resources :emails, only: [:new, :create, :show], controller: 'events/emails'

    resources :sections, only: [:create, :update, :destroy] do
      post :arrange, on: :collection
    end

    collection do
      get :feed
    end

    resources :rsvps, except: [:show, :index, :new] do
      get :quick_destroy_confirm

      new do
        get :volunteer
        get :learn
      end

      resources :surveys, only: [:new, :create]
    end

    resources :surveys, only: [:new, :index] do
      get :preview, on: :collection
    end

    resources :event_sessions, only: [:index, :show, :destroy] do
      resources :checkins, only: [:index, :create, :destroy]
    end

    resources :organizer_tools, only: [:index], controller: "events/organizer_tools"
    controller "events/organizer_tools" do
      get "send_survey_email"
      resource :survey, only: [:edit], controller: "events/surveys"
      get "organize_sections"
      get "diets"
      get "rsvp_preview"
      get "close_rsvps"
      get "reopen_rsvps"
      post "send_announcement_email"
    end

    collection do
      resources :unpublished_events, only: [:index], controller: "events/unpublished_events" do
        post "publish"
        post "flag"
      end
    end

    member do
      get "levels"
    end
  end

  resources :external_events, except: [:show]

  get "/about" => "static_pages#about"
  get "/admin_dashboard" => "admin_pages#admin_dashboard"
  scope '/admin_dashboard', controller: :admin_pages do
    get "send_test_email"
    get "raise_exception"
  end

  if Rails.env.development?
    get "/style_guide" => "static_pages#style_guide"
  end
end
