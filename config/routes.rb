Rails.application.routes.draw do
  root to: redirect("users/edit")

  get "account_confirmations/index", to: "account_confirmation#index"
  put "account_confirmations", to: "account_confirmation#approve_all"
  put "account_confirmations/:id", to: "account_confirmation#approve", as: "approve_user"
  delete "account_confirmations", to: "account_confirmation#block_all"
  delete "account_confirmations/:id", to: "account_confirmation#block", as: "block_user"
  
  get "profile/index"

  devise_for :users,
             controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
end
