Rails.application.routes.draw do
  get 'permissions/create'

  get 'resources/index'

  root to: 'home#index'

  get "account_confirmations/index", to: "account_confirmation#index"
  put "account_confirmations", to: "account_confirmation#approve_all"
  put "account_confirmations/:id", to: "account_confirmation#approve", as: "approve_user"
  delete "account_confirmations", to: "account_confirmation#block_all"
  delete "account_confirmations/:id", to: "account_confirmation#block", as: "block_user"

  devise_for :users,
             controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  resources :patients, except: [:edit, :update]
  resources :pdp, only: :index

  resources :resources, except: [:show, :update, :edit]
  resources :permissions, only: [:new, :create, :destroy]

  # Help
  get 'help' => 'help#index'
  get 'help/:category/:file' => 'help#show',
       as: :help_page,
       constraints: { category: /.*/, file: /[^\/\.]+/ }
end
