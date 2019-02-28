# frozen_string_literal: true

module PipelineSteps
  module Singularity
    class Builder
      def initialize(pipeline, name, registry_url, container_name, container_tag)
        @pipeline = pipeline
        @name = name
        @registry_url = registry_url
        @container_name = container_name
        @container_tag = container_tag
      end

      def call
        container_registry = ContainerRegistry.find_or_create_by!(registry_url: @registry_url)

        SingularityComputation.create!(
          pipeline: @pipeline,
          user: @pipeline.user,
          pipeline_step: @name,
          container_registry_id: container_registry.id,
          container_name: @container_name,
          container_tag: @container_tag
        )
      end
    end
  end
end