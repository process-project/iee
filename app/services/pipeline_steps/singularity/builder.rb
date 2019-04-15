# frozen_string_literal: true

module PipelineSteps
  module Singularity
    class Builder
      def initialize(pipeline, name, user_parameters, parameters = [])
        @pipeline = pipeline
        @name = name
        @user_parameters = user_parameters
        @parameters = parameters
      end

      def call
        container_registry = ContainerRegistry.
                             find_or_create_by!(registry_url: @user_parameters[:registry_url])

        @staging_logger ||= Logger.new(Rails.root.join('log', 'debug.log'))
        @staging_logger.debug("permitted_attributes in builder: #{tmp_permitted_attributes}")

        SingularityComputation.create!(
          pipeline: @pipeline,
          user: @pipeline.user,
          pipeline_step: @name,
          container_registry_id: container_registry.id,
          container_name: @user_parameters[:container_name],
          container_tag: @user_parameters[:container_tag]
        )
      end

      def tmp_permitted_attributes
        tmp = []
        @parameters.each do |parameter|
          tmp.push parameter.label.to_sym
        end

        return tmp
      end
    end
  end
end
