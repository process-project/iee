# frozen_string_literal: true

module PipelineSteps
  module Cloudify
    class Builder
      def initialize(pipeline, name, _params = {})
        Rails.logger.debug("Builder initialized with params: #{pipeline.inspect} #{name.inspect}")

        @pipeline = pipeline
        @name = name
      end

      def call
        CloudifyComputation.create!(
          pipeline: @pipeline,
          user: @pipeline.user,
          pipeline_step: @name
        )
      end
    end
  end
end
