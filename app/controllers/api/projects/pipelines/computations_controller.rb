# frozen_string_literal: true

require 'json-schema'
require 'securerandom'

module Api
  module Projects
    module Pipelines
      class ComputationsController < Api::ApplicationController
        include ProjectsHelper
        include PipelinesHelper

        before_action :parse_and_validate_create, only: :create
        before_action :fetch_and_validate_project
        before_action :fetch_and_validate_pipeline
        before_action :fetch_and_validate_computation, only: :show

        def index
          a = Flow.flows_for(@project.downcase.to_sym)[@pipeline]
          render json: a.to_json, status: :ok
        end

        def show
          @pipeline_instance = Pipeline.find(@computation)
          computations = @pipeline_instance.computations

          result = {}

          computations.each do |computation|
            result[computation.pipeline_step] = computation.status
          end
          render json: result.to_json, status: :ok
          # # TODO error handling
        end

        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/AbcSize
        def create
          project = Project.find_by!(project_name: @project)
          owners = { project: project, user: current_user }

          base_attrs = { flow: @pipeline, name: "random_hash#{SecureRandom.hex}",
                         mode: 'automatic' }

          steps_attrs = {}

          @json['steps'].each do |step|
            steps_attrs[step['step_name']] = step['parameters']
          end

          pipeline_attributes = ActionController::Parameters.new(base_attrs.merge(steps_attrs))
          pipeline_instance = Pipeline.new(base_attrs.merge(owners))

          # TODO: CHECK FOR WEBDAV HTTP ERRORS
          ::Pipelines::Create.new(pipeline_instance, pipeline_attributes).call

          if pipeline_instance.errors.empty?
            project.execute_data_sync(current_user)
            ::Pipelines::StartRunnable.new(pipeline_instance).call
            render json: pipeline_instance.id.to_json, status: :ok
          else
            render json: ['error'].to_json, status: :unauthorized
          end
        end
        # rubocop:enable Metrics/MethodLength
        # rubocop:enable Metrics/AbcSize

        private

        def parse_and_validate_create
          schema = File.read(Rails.root.join('config', 'schemas', 'computation-schema.json'))
          @json = JSON.parse(request.body.read)
          api_error(status: :bad_request) unless JSON::Validator.validate(schema, @json)
        end

        def fetch_and_validate_project
          @project = params['project_id']
          api_error(status: 404) unless available_api_projects.include?(@project)
        end

        def fetch_and_validate_pipeline
          @pipeline = params['pipeline_id']
          api_error(status: 404) unless available_flows_for(@project).include?(@pipeline)
        end

        def fetch_and_validate_computation
          @computation = params['id']
          database_ids = Project.find_by(project_name: @project).
                         pipelines.where(flow: @pipeline).ids
          api_error(status: 404) unless database_ids.include?(@computation.to_i)
        end
      end
    end
  end
end
