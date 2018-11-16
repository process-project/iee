# frozen_string_literal: true

module Admin
  module Users
    class DevicesController < ApplicationController
      # before_action :find_and_authorize_user

      def index
        authorize(Device)
        @devices = policy_scope(Device)
        @devices = @devices.where(user_id: params[:user_id])
      end

      # def show
      #
      # end

      # private
      #
      # def find_and_authorize_user
      #   @user = User.find(params[:id])
      #   authorize(@user)
      # end
    end
  end
end