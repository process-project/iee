# frozen_string_literal: true

module PipelineSteps
  module Singularity
    class Builder
      def initialize(pipeline, name, parameter_values, parameters = [])
        @staging_logger ||= Logger.new(Rails.root.join('log', 'debug.log'))

        @pipeline = pipeline
        @name = name
        @parameter_values = safe_parameter_values(parameter_values, parameters)
        @parameters = parameters

        @staging_logger.debug("safe_parameter_values: #{@parameter_values}")
        @staging_logger.debug("parameters: #{@parameters}")
        @staging_logger.debug("rails_parameters: #{parameter_values}")
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

      def safe_parameter_values(parameter_values, parameters)
        parameter_values.permit(permitted_parameters(parameters)).to_h.symbolize_keys
      end

      def permitted_parameters(parameters)
        attributes = [:container_name, :container_tag, :hpc]

        parameters.each do |parameter|
          attributes.push parameter.label.to_sym
        end

        attributes
      end
    end
  end
end
