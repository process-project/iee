# frozen_string_literal: true

module Profiles
  class DevicesController < ApplicationController
    def show
      @devices = current_user.devices
    end
  end
end
