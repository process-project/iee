# frozen_string_literal: true

module Users
  class Base
    attr_reader :user

    def initialize(current_user, user)
      @current_user = current_user
      @user = user
    end

    def call
      if self?
        :self
      elsif last_group_owner?
        :last_group_owner
      elsif perform!
        :ok
      else
        :error
      end
    end

    protected

    def self?
      @current_user == @user
    end

    def perform!; end

    private

    def last_group_owner?
      ExclusivelyOwnedGroups.new(@user).call.count.positive?
    end
  end
end
