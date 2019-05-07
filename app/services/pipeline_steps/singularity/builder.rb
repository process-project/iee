# frozen_string_literal: true

module PipelineSteps
  module Singularity
    class Builder
      def initialize(pipeline, name, user_parameters, parameters = [])
        @pipeline = pipeline
        @name = name
        @parameters = parameters
        @user_parameters = safe_user_parameters(user_parameters, parameters)
      end

      def call
        SingularityComputation.create!(
          pipeline: @pipeline,
          user: @pipeline.user,
          pipeline_step: @name,
          container_name: @user_parameters[:container_name],
          container_tag: @user_parameters[:container_tag],
          user_parameters: @user_parameters.inspect
        )
      end

      def safe_user_parameters(user_parameters, parameters)
        user_parameters.permit(permitted_parameters(parameters)).to_h.symbolize_keys
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
