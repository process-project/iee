# frozen_string_literal: true

module PipelineSteps
  module Singularity
    class Builder
      def initialize(pipeline, name, user_parameters, parameters = [])
        @pipeline = pipeline
        @name = name
        @parameters = parameters
        @user_parameters = user_parameters.permit(permitted_parameters(parameters)).to_h
      end

      def call
        container_registry = ContainerRegistry.
                             find_or_create_by!(registry_url: @user_parameters[:registry_url])

        SingularityComputation.create!(
          pipeline: @pipeline,
          user: @pipeline.user,
          pipeline_step: @name,
          container_registry_id: container_registry.id,
          container_name: @user_parameters[:container_name],
          container_tag: @user_parameters[:container_tag],
          user_parameters: @user_parameters.inspect
        )
      end

      def permitted_parameters(parameters)
        attributes = []

        parameters.each do |parameter|
          attributes.push parameter.label.to_sym
        end

        attributes
      end
    end
  end
end
