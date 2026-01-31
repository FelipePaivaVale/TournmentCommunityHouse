# config/routes.rb
Rails.application.routes.draw do
  # Devise for Users (public area)
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    confirmations: 'users/confirmations',
    passwords: 'users/passwords',
    unlocks: 'users/unlocks'
  }

  devise_for :admins, path: 'admin', controllers: {
    sessions: 'admins/sessions',
    registrations: 'admins/registrations',
    passwords: 'admins/passwords',
    unlocks: 'admins/unlocks'
  }

  root 'home#index'
  
  get 'search', to: 'home#search'
  post 'lol_profiles/:id/link', to: 'lol_profiles#link', as: 'link_lol_profile'
  get 'profile', to: 'users#profile'
  get 'dashboard', to: 'users#dashboard'
  
  namespace :admin do
    root 'dashboard#index'
    
    get 'dashboard', to: 'dashboard#index'
    
    # User management
    resources :users do
      member do
        patch :promote_to_organizer
        patch :promote_to_admin
        patch :demote_to_player
      end
    end
    
    
    
    # System settings
    resources :settings, only: [:index, :update]
    
    # Reports
    get 'reports', to: 'reports#index'
    get 'analytics', to: 'analytics#index'
  end


  resources :teams
  resources :players, only: [:show, :index]
end