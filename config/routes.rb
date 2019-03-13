# frozen_string_literal: true

# rubocop:disable BlockLength
Rails.application.routes.draw do
  get 'access_policies/create'

  get 'resources/index'

  root to: redirect(path: '/projects')

  devise_for :users,
             controllers: {
               omniauth_callbacks: 'users/omniauth_callbacks',
               registrations: 'users/registrations',
               sessions: 'users/sessions'
             }

  ## User profile section routes
  resource :profile, only: [:show, :update] do
    scope module: :profiles do
      resource :account, only: [:show, :update]
      resource :password, only: [:show, :update]
      resource :plgrid, only: [:show, :destroy]
    end
  end

  resources :projects, except: [:edit, :update], constraints: { id: /.+/ } do
    scope module: :projects do
      resources :comparisons, only: [:index]
      resources :pipelines do
        scope module: :pipelines do
          resources :computations, only: [:show, :update]
        end
      end
    end
  end

  namespace :api do
    resources :pdp, only: :index
    resources :sessions, only: :create
    resources :policies, only: [:create, :index]
    delete 'policies', to: 'policies#destroy'
    resources :policy_entities, only: :index
    # LOBCDER API webhook
    post 'staging' => 'staging#notify'
  end

  resources :services do
    scope module: :services do
      resources :local_policies
      resources :global_policies
    end
  end
  resources :groups do
    scope module: :groups do
      resources :user_groups, only: [:create, :destroy]
    end
  end
  resources :resources, only: :index do
    scope module: :resources do
      resources :access_policies, only: [:create, :destroy]
      resources :resource_managers, only: [:create, :destroy]
    end
  end
  resources :cloud_resources, only: :index
  resources :data_sets, only: :show

  # Help
  get 'help' => 'help#index'
  get 'help/:category/:file' => 'help#show',
      as: :help_page,
      constraints: { category: /.*/, file: %r{[^/\.]+} }

  # File Store
  get 'file_store' => 'file_store#index'

  namespace :admin do
    resources :users
  end

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
# rubocop:enable BlockLength
