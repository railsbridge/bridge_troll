Bridgetroll::Application.routes.draw do
  root :to => "events#index"

  devise_for :users

  resources :users do
    resource :profile, :only => [:edit, :update, :show]
  end

  resources :locations

  resources :events do
    resources :organizers, :only => [:index, :create, :destroy]
    resources :rsvps, :except => :index
  end
end
