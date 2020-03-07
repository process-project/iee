# frozen_string_literal: true

module Api
  class ProjectsController < Api::ApplicationController
    def index
      render json: %w[UC2].to_json, status: :ok
    end
  end
end
