Rails.application.routes.draw do
  resources :tax_and_discounts
  resources :line_items
  resources :products
  resources :categories
  devise_for :users

  namespace :invoices do
    resources :line_items, only: [:create, :destroy]
    resources :tax_and_discount_polies, only: [:create, :destroy]
    post 'calculator', to: 'calculator#calculate_sub_total_and_total'
  end

  resources :invoices do
    collection do
      post 'calculate_sub_total'
    end
  end
  # devise_for :admin_users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
  #  Defines the root path route ("/")
  # root "posts#index"
end
