# frozen_string_literal: true
class ResourcesController < ApplicationController
  def index
    @resources = policy_scope(Resource).order(:name)
  end

  def new
    @services = current_user.services
  end
end
