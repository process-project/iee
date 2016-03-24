Rails.application.routes.draw do
  root to: redirect("account_confirmation/index")

  get "account_confirmation/index"

  devise_for :users,
             controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
end
