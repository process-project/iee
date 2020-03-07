# frozen_string_literal: true

module Api
  module Projects
    class PipelinesController < Api::ApplicationController
      def index
        return api_error(status: 404) unless params['project_id'] == 'UC2'
        render json: %w[P1 P2 P3 P4].to_json, status: :ok
      end
    end
  end
end
