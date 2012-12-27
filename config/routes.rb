Bridgetroll::Application.routes.draw do
  root :to => "events#index"

  devise_for :users

  resources :event_organizers, :only => [:index, :create, :destroy]
  resources :locations
  resources :events
  resources :volunteer_rsvps, :only => [:create,:update]

  match 'volunteer/search', :to => 'volunteer_rsvps#index', :as => :volunteersearch
 
end
