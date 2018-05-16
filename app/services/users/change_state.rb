# frozen_string_literal: true

module Users
  class ChangeState
    def initialize(current_user, user, new_state)
      @current_user = current_user
      @user = user
      @new_state = new_state
    end

    def call
      if block_self?
        :block_self
      elsif perform!
        :ok
      else
        :error
      end
    end

    private

    def block_self?
      @current_user == @user && @new_state == 'blocked'
    end

    def perform!
      @user.update_attributes(state: @new_state)
    end
  end
end
