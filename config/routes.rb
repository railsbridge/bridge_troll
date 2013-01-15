Bridgetroll::Application.routes.draw do
  root :to => "events#index"

  devise_for :users

  resources :users do
    resource :profile, :only => [:edit, :update, :show]
  end

  resources :locations

  resources :events do
    resources :organizers, :only => [:index, :create, :destroy]
  end

  resources :volunteer_rsvps, :only => [:create,:destroy]
end
