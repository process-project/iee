# frozen_string_literal: true

module PipelineSteps
  module Singularity
    class Builder
      def initialize(pipeline, name, parameter_values, parameters = [])
        @pipeline = pipeline
        @name = name
        @parameters = parameters
        @parameter_values = safe_parameter_values(parameter_values, parameters)
      end

      def call
        SingularityComputation.create!(
          pipeline: @pipeline,
          user: @pipeline.user,
          pipeline_step: @name,
          container_name: @parameter_values[:container_name],
          container_tag: @parameter_values[:container_tag],
          hpc: @parameter_values[:hpc]
          parameter_values: @parameter_values.expect[:container_name, :container_tag, :hpc]
        )
      end

      def safe_parameter_values(parameter_values, parameters)
        parameter_values.permit(permitted_parameters(parameters)).to_h.symbolize_keys
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
