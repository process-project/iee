# frozen_string_literal: true
module Users
  class RegistrationsController < Devise::RegistrationsController
    def create
      super do |resource|
        Notifier.user_registered(resource).deliver_later if resource.persisted?
      end
    end
  end
end
