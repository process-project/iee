# frozen_string_literal: true

module PipelineSteps
  module StagingIn
    class Builder
      def initialize(pipeline, name, src_host, src_path,
                     dest_host, dest_path, params = {})
        @pipeline = pipeline
        @name = name
        @src_host = src_host
        @src_path = src_path
        @dest_host = dest_host
        @dest_path = dest_path
      end

      def call
        StagingInComputation.create!(
          pipeline: @pipeline,
          user: @pipeline.user,
          pipeline_step: @name,
          src_host: @src_host,
          input_path: @src_path,
          dest_host: @dest_host,
          output_path: @dest_path)
      end
    end
  end
end