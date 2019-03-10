# frozen_string_literal: true

module Admin
  module Users
    class DevicesController < ApplicationController
      before_action :find_and_authorize_user

      def index
        @devices = @user.devices
      end

      private

      def find_and_authorize_user
        @user = User.find(params[:user_id])
        authorize(@user)
      end
    end
  end
end
