Rails.application.routes.draw do
  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks"}
  devise_scope :user do
    get "sign_in", to: "devise/sessions#new", as: :new_user_session
    match "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session, via: [:get, :delete]
  end

  resources :sites do
    resources :subnets, only: [:new, :create]
  end

  resources :subnets, only: [:show, :edit, :update, :destroy] do
    resource :options, only: [:new, :create, :edit, :update, :destroy]
  end

  resources :zones, only: [:index, :new, :create, :edit, :update, :destroy]

  get "/healthcheck", to: "monitoring#healthcheck"

  root "home#index"
end
