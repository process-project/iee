# frozen_string_literal: true

module PipelineSteps
  module Singularity
    class Builder
      def initialize(pipeline, name, parameter_values, parameters = [])
        @pipeline = pipeline
        @name = name
        @parameter_values = safe_parameter_values(parameter_values, parameters)
        @parameters = parameters
      end

      def call
        SingularityComputation.create!(
          pipeline: @pipeline,
          user: @pipeline.user,
          pipeline_step: @name,
          container_name: @parameter_values[:container_name],
          container_tag: @parameter_values[:container_tag],
          hpc: @parameter_values[:hpc],
          parameter_values: @parameter_values.except(:container_name, :container_tag, :hpc)
        )
      end

      private

      def safe_parameter_values(parameter_values, parameters)
        attributes = parameter_attributes(parameters)
        parameter_values.require(attributes)
        parameter_values.permit(attributes).to_h.symbolize_keys
      end

      def parameter_attributes(parameters)
        attributes = [:container_name, :container_tag, :hpc]

        parameters.each do |parameter|
          attributes.push parameter.label.to_sym
        end

        attributes
      end
    end
  end
end
