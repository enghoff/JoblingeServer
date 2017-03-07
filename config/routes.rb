Rails.application.routes.draw do

  resources :user_sessions, only: [:create, :destroy]

  get "logout" => "user_sessions#destroy", as: :logout
  get "login"  => "user_sessions#create",  as: :login

  get '/' => "user_sessions#new",  :constraints => UserNotLoggedConstraint.new, :as => "root"
  get '/' => "admin/users#index",  :constraints => UserLoggedConstraint.new

  namespace :admin do
    resources :users do
      member do
        post :resend_registration_mail
        get  :statistics
        get  :progress
      end
    end
    resources :groups
    resources :locations
    root controller: :users, action: :index
  end

  resources :password_resets

  namespace :api do
    resources :users, only: [:update, :show] do
      member do
        patch :change_password
      end
      collection do
        patch :register
      end
      resource :game_data, only: [:update, :show]
    end
    resources :user_sessions, only: [ :create ] do
      collection do
        delete :reset
      end
    end
    resources :password_resets, only: [:create, :update], param: :token
    resources :player_sessions, except: [:new, :edit]
  end

  match "/dev/:action" => "dev#:action", :via => :all, :as => 'dev'

end
