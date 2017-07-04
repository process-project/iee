# frozen_string_literal: true

module Users
  class AddToDefaultGroups
    def initialize(user)
      @user = user
    end

    def call
      @user.groups << Group.where(default: true).
                      where.not(id: @user.groups.pluck(:id))
    end
  end
end
