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
          # a = Flow.flows_for(@project.downcase.to_sym)[@pipeline]
          render json: current_user.to_json, status: :ok
        end

        def show # TODO
          result = {}
          pipeline = Pipeline.where(name: @pipeline)

          pipeline = Pipeline.where(flow: @pipeline)
          computations = pipeline.computations
          # computations = somehow_from_this(pipeline_id)
          computations.each do |computation|
            result[computation.pipeline_step] = computation.status
          end
          
          render json: result.to_json, status: :ok
          # TODO error handling
        end

        def create # TO TEST 
          project = Project.find_by!(project_name: @project)
          owners = { project: project, user: current_user }

          base_attrs = {flow: @pipeline, name: "hash_123_randomHASH", mode: "automatic"}

          steps_attrs = {}

          @json["steps"].each do |step|
            steps_attrs[step["step_name"]] = step["parameters"]
          end

          pipeline_attributes = base_attrs + steps_attrs

          pipeline_instance = Pipeline.new(pipeline_attributes.merge(owners))
          ::Pipelines::Create.new(pipeline_instance, pipeline_attributes).call
          ::Pipelines::StartRunnable.new(pipeline_instance).call

          render json: pipeline_instance.id.to_json, status: :ok
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

          # api_error(status: 404) unless %w[P1 P2 P3 P4].include?(@pipeline)
        end

        def fetch_and_validate_computation
          @computation = params['id']

          api_error(status: 404) unless %w[J1 J2 J3 J4].include?(@computation)
        end
      end
    end
  end
end
