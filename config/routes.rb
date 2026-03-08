Rails.application.routes.draw do
  resource :session
  resource :registration, only: [ :new, :create ]
  resources :passwords, param: :token

  # Redirect to localhost from 127.0.0.1 to use same IP address with Vite server
  constraints(host: "127.0.0.1") do
    get "(*path)", to: redirect { |params, req| "#{req.protocol}localhost:#{req.port}/#{params[:path]}" }
  end

  namespace :api do
    namespace :v1 do
      resources :channels, only: [ :index, :create ], param: :uuid do
        resources :channel_messages, only: [ :index, :create ], path: "messages"
      end
    end
  end

  root "welcome#home"
  mount MissionControl::Jobs::Engine, at: "/jobs"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
