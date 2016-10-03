# frozen_string_literal: true
class CloudResourcesController < ApplicationController
  def index
    puts current_user.token
  end
end
