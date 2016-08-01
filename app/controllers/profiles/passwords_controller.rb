# frozen_string_literal: true
module Profiles
  class PasswordsController < ApplicationController
    def show
    end

    def update
      if !current_user.valid_password?(current_password)
        current_user.errors.add(:current_password,
                                'You must provide a valid current password')
        render 'show'
      elsif current_user.update_attributes(user_params)
        redirect_to new_user_session_path,
                    notice: 'Password was successfully updated. Please login with it'
      else
        render 'show'
      end
    end

    private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def current_password
      params.require(:user).permit(:current_password)[:current_password]
    end
  end
end
