# frozen_string_literal: true

require 'json-schema'

module Api
  module Projects
    module Pipelines
      class ComputationsController < Api::ApplicationController
        before_action :parse_and_validate_create, only: :create
        before_action :fetch_and_validate_project
        before_action :fetch_and_validate_pipeline
        before_action :fetch_and_validate_computation, only: :show

        def index
          render json: %w[J1 J2 J3 J4].to_json, status: :ok
          #  More complex example
          #  render json: { computations: [{ id: 'J1', status: 'finished' },
          #                                { id: 'J2', status: 'queuing' },
          #                                { id: 'J3', status: 'running' }] }.to_json, status: :ok
        end

        def show
          render json: { id: params[:id], status: 'running' }.to_json, status: :ok
        end

        def create
          # FIXME: DO something with @json that is more intelligent than resending it back ;)
          render json: @json.to_json, status: :ok
        end

        private

        def parse_and_validate_create
          schema = File.read(Rails.root.join('config', 'schemas', 'computation-schema.json'))
          @json = JSON.parse(request.body.read)
          api_error(status: :bad_request) unless JSON::Validator.validate(schema, @json)
        end

        def fetch_and_validate_project
          @project = params['project_id']

          api_error(status: 404) unless @project == 'UC2'
        end

        def fetch_and_validate_pipeline
          @pipeline = params['pipeline_id']

          api_error(status: 404) unless %w[P1 P2 P3 P4].include?(@pipeline)
        end

        def fetch_and_validate_computation
          @computation = params['id']

          api_error(status: 404) unless %w[J1 J2 J3 J4].include?(@computation)
        end
      end
    end
  end
end
