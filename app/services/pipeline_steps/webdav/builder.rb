# frozen_string_literal: true

module PipelineSteps
  module Webdav
    class Builder
      def initialize(pipeline, name, _params = {})
        @pipeline = pipeline
        @name = name
      end

      def call
        WebdavComputation.create!(
          pipeline: @pipeline,
          user: @pipeline.user,
          pipeline_step: @name,
          output_path: @pipeline.outputs_dir
        )
      end
    end
  end
end
