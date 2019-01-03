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
        SingularityComputation.create!(
          pipeline: @pipeline,
          user: @pipeline.user,
          pipeline_step: @name,
          registry_url: @registry_url,
          container_name: @container_name,
          container_tag: @container_tag
        )
      end
    end
  end
end
