class AccountConfirmationController < ApplicationController
  def index
    @users = {}
    @users[:confirmed] = User.where(approved: true)
    @users[:not_confirmed] = User.where(approved: false)
    @user_confirmations = @users[:not_confirmed].exists?
  end
end
