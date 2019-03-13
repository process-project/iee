# frozen_string_literal: true

module Profiles
  class DevicesController < ApplicationController
    def index
      @devices = current_user.devices
    end
  end
end
