# frozen_string_literal: true

module Api
  module Projects
    class PipelinesController < Api::ApplicationController
      def index
        return api_error(status: 404) unless params['project_id'] == 'UC2'
        flows = Flow.flows_for(params['project_id'].downcase.to_sym).keys
        render json: flows.to_json, status: :ok
      end
    end
  end
end
