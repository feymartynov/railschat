Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  root to: 'chats#index'

  resources :chats, only: %i(show create) do
    post :leave, on: :member
  end

  resources :users, only: %i(new create edit update)
  resources :sessions, only: %i(new create destroy)

  get 'login' => 'sessions#new', as: :login
  get 'logout' => 'sessions#destroy', as: :logout
end
