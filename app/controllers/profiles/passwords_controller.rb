# frozen_string_literal: true

module Profiles
  class PasswordsController < ApplicationController
    def show; end

    def update
      if !current_user.valid_password?(current_password)
        wrong_password!
        render 'show'
      elsif current_user.update(user_params)
        redirect_to new_user_session_path,
                    notice: t('profiles.passwords.update.success')
      else
        render 'show'
      end
    end

    private

    def wrong_password!
      current_user.errors.add(:current_password,
                              t('user.wrong_password'))
    end

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def current_password
      params.require(:user).permit(:current_password)[:current_password]
    end
  end
end
