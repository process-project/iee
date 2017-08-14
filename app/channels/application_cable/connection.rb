# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags 'ActionCable', current_user.email
    end

    private

    def find_verified_user
      verified_user = User.find_by(id: cookies.signed['user.id'])

      verified_user || reject_unauthorized_connection
    end
  end
end
