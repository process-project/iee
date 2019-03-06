# frozen_string_literal: true

module PipelineSteps
  module Webdav
    class Builder
      def initialize(pipeline, name, params = {})
        @pipeline = pipeline
        @name = name
        @run_mode = params[:run_mode]
      end

      def call
        WebdavComputation.create!(
          pipeline: @pipeline,
          user: @pipeline.user,
          run_mode: @run_mode,
          pipeline_step: @name,
          output_path: @pipeline.outputs_dir
        )
      end
    end
  end
end
