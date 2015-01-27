Rails.application.routes.draw do
  devise_for :users, skip: :registrations
  devise_scope :user do
    resource :registration,
      only: [:edit, :update],
      path: 'users',
      path_names: { new: 'sign_up' },
      controller: 'devise/registrations',
      as: :user_registration do
        get :cancel
      end
  end
  
  root 'home#index'
  resources :girls, :tags, only: [:show]

  resources :videos, only: [:index, :show] do
    get :search, on: :collection
  end


  namespace :admin do
    resources :users, except: :destory
  end
end