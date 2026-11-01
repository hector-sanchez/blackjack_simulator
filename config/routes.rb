Rails.application.routes.draw do
  root "games#index"

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :blackjack do
    resources :sessions, only: %i[create show] do
      member do
        post :hit
        post :stand
      end
    end
  end
end
