# frozen_string_literal: true
module Users
  class RegistrationsController < Devise::RegistrationsController
    def create
      super do |resource|
        Notifier.user_registered(resource).deliver_later if resource.persisted?
        Users::AddToDefaultGroups.new(resource).call
      end
    end

    protected

    def after_inactive_sign_up_path_for(_resource)
      new_user_session_path
    end
  end
end
