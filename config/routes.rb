Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  resources :users
  get "signup", to: "users#new"
  post "signup", to: "users#create"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  root "sessions#new"

  resources :tasks
  get "tasks/:id/images", to: "tasks#image", as: "image_task"

  get "/auth/google/login", to: "sessions#google_login", as: :google_login
  get "/auth/google/login/callback", to: "sessions#google_callback"

  get "/auth/google/calendar", to: "google_calendar_integrations#connect"
  get "/auth/google/calendar/callback", to: "google_calendar_integrations#callback"

  resource :google_calendar_integration, only: [ :show, :update, :destroy ]

  resources :google_calendar_integration do
    member do
      patch "toggle_sync", to: "google_calendar_integrations#toggle_sync"
    end
  end
end
