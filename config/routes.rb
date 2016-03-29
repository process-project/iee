Rails.application.routes.draw do
  root to: redirect("profile/index")

  get "account_confirmation/index"
  put "account_confirmation/approve_all"
  put "account_confirmation/approve/:id", to: "account_confirmation#approve", as: "approve_user"
  put "account_confirmation/block_all"
  put "account_confirmation/block/:id", to: "account_confirmation#block", as: "block_user"
  
  get "profile/index"

  devise_for :users,
             controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
end
