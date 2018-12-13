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

      #TODO
      def call
        RimrockComputation.create!(
          pipeline: @pipeline,
          user: @pipeline.user,
          tag_or_branch: nil,
          pipeline_step: @name
        )
      end
    end
  end
end