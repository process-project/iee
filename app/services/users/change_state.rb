# frozen_string_literal: true

module Users
  class ChangeState < Base
    def initialize(current_user, user, new_state)
      super(current_user, user)
      @new_state = new_state
    end

    protected

    def self?
      super && @new_state == 'blocked'
    end

    def perform!
      user.update_attributes(state: @new_state)
    end
  end
end
