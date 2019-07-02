# frozen_string_literal: true

module PipelineSteps
  module StagingIn
    class Builder
      def initialize(pipeline, name, src_host, src_path,
                     dest_host, dest_path, tmp_output_file = nil)
        @pipeline = pipeline
        @name = name
        @src_host = src_host
        @src_path = src_path
        @dest_host = dest_host
        @dest_path = dest_path
        @tmp_output_file = tmp_output_file
      end

      def call
        StagingInComputation.create!(pipeline: @pipeline,
                                     user: @pipeline.user,
                                     pipeline_step: @name,
                                     src_host: @src_host,
                                     input_path: @src_path,
                                     dest_host: @dest_host,
                                     output_path: @dest_path,
                                     tmp_output_file: @tmp_output_file)
      end
    end
  end
end
