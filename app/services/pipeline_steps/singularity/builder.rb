# frozen_string_literal: true

module PipelineSteps
  module Singularity
    class Builder
      def initialize(pipeline, name, params = {})
        @pipeline = pipeline
        @name = name
        @registry_url = params[:registry_url]
        @container_name = params[:container_name]
      end

      # TODO
      def call
        SingularityComputation.create!(
          pipeline: @pipeline,
          user: @pipeline.user,
          pipeline_step: @name,
          registry_url: 'Placeholder registry url',
          container_name: 'Placeholder container name'
        )
      end
    end
  end
end
