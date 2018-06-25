# frozen_string_literal: true

module Users
  class Destroy < Base
    protected

    def perform!
      @user.destroy
    end
  end
end
