# frozen_string_literal: true

module Api
  module Projects
    class PipelinesController < Api::ApplicationController
      include ProjectsHelper
      include PipelinesHelper

      def index
        return api_error(status: 404) unless available_api_projects.include?(params['project_id'])
        flows = available_flows_for(params['project_id'])
        render json: flows.to_json, status: :ok
      end
    end
  end
end
