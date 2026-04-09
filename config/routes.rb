Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root "dashboard#index", as: :authenticated_root
  end

  unauthenticated do
    root "home#index"
  end

  resources :wallets do
    resources :transactions
  end

  resources :categories
  get "dashboard", to: "dashboard#index"
  get "metrics", to: "metrics#index"
end
