# frozen_string_literal: true

module Api
  class ProjectsController < Api::ApplicationController
    include ProjectsHelper

    def index
      render json: available_api_projects.to_json, status: :ok
    end
  end
end
