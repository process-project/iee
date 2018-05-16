# frozen_string_literal: true

module Users
  class Destroy
    def initialize(current_user, user)
      @current_user = current_user
      @user = user
    end

    def call
      if self?
        :self
      elsif perform!
        :ok
      else
        :error
      end
    end

    private

    def self?
      @current_user == @user
    end

    def perform!
      @user.destroy
    end
  end
end
