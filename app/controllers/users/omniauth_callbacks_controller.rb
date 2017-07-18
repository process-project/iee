# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token, only: [:open_id, :failure]

    def open_id
      new_user = user.new_record?
      user.save

      if user.persisted?
        success(new_user)
      elsif user.errors.messages.include?(:email)
        email_error
      else
        plgrid_error
      end
    end

    private

    def after_sign_in_path_for(resource)
      origin = request.env['omniauth.origin']

      if origin == new_user_session_url
        super
      else
        origin || stored_location_for(resource) || root_path
      end
    end

    def success(new_user)
      sign_in_and_redirect user, event: :authentication
      set_flash_message(:notice, :success, kind: 'PLGrid') if is_navigational_format?
      Users::AddToDefaultGroups.new(user).call if new_user
    end

    def email_error
      set_flash_message(:alert, :email_not_unique)
      redirect_to new_user_session_path
    end

    def plgrid_error
      set_flash_message(:alert, :failure, kind: 'PLGrid')
      redirect_to root_url
    end

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
