# frozen_string_literal: true
module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token, only: [:open_id, :failure]

    def open_id
      if user.persisted?
        sign_in_and_redirect user, event: :authentication
        if is_navigational_format?
          set_flash_message(:notice, :success, kind: 'PLGrid')
        end
      elsif user.errors.messages.include?(:email)
        set_flash_message(:alert, :email_not_unique)
        redirect_to new_user_session_path
      else
        set_flash_message(:alert, :failure, kind: 'PLGrid')
        redirect_to root_url
      end
    end

    private

    def user
      @user ||= if current_user
                  current_user.plgrid_connect(auth)
                else
                  User.from_plgrid_omniauth(auth)
                end
    end

    def auth
      @auth ||= request.env['omniauth.auth']
    end
  end
end
