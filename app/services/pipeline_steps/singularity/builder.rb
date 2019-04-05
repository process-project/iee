# frozen_string_literal: true

module PipelineSteps
  module Singularity
    class Builder
      def initialize(pipeline, name, user_parameters, parameters = [])
        @pipeline = pipeline
        @name = name
        @user_parameters = user_parameters
        @parameters = parameters # TO DELETE
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
          user_parameters: to_my_own_hash(@user_parameters).inspect
        )
      end

      def to_my_own_hash(parameters)
        parameters.to_unsafe_h.inject({}) do |memo, (k, v)|
          memo[k.to_sym] = v
          memo
        end
      end
    end
  end
end
