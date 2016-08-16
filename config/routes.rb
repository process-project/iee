# frozen_string_literal: true
Rails.application.routes.draw do
  get 'access_policies/create'

  get 'resources/index'

  root to: 'home#index'

  get 'account_confirmations/index', to: 'account_confirmation#index'
  put 'account_confirmations', to: 'account_confirmation#approve_all'
  put 'account_confirmations/:id', to: 'account_confirmation#approve', as: 'approve_user'
  delete 'account_confirmations', to: 'account_confirmation#block_all'
  delete 'account_confirmations/:id', to: 'account_confirmation#block', as: 'block_user'

  devise_for :users,
             controllers: {
               omniauth_callbacks: 'users/omniauth_callbacks',
               registrations: 'users/registrations'
             }

  ## User profile section routes
  resource :profile, only: [:show, :update] do
    scope module: :profiles do
      resource :account, only: [:show, :update]
      resource :password, only: [:show, :update]
      resource :plgrid, only: [:show, :destroy]
    end
  end

  resources :patients, except: [:edit, :update]

  namespace :api do
    resources :pdp, only: :index
    resources :sessions, only: :create
    resources :policies, only: [ :create, :index ]
    delete 'policies', to: 'policies#destroy'
    resources :policy_entities, only: :index
  end

  resources :resources, except: [:show, :update, :edit]
  resources :access_policies, only: [:new, :create, :destroy]
  resources :computations, only: [:show, :create]

  # Help
  get 'help' => 'help#index'
  get 'help/:category/:file' => 'help#show',
      as: :help_page,
      constraints: { category: /.*/, file: %r{[^/\.]+} }

  # File Store
  get 'file_store' => 'file_store#index'

  # Sidekiq monitoring
  authenticate :user, ->(u) { u.admin? } do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
    namespace :admin do
      resource :job, only: :show
    end
  end

  match '/404', to: 'errors#not_found', via: :all
  match '/422', to: 'errors#unprocessable', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
end
