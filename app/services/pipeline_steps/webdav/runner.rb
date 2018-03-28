# frozen_string_literal: true

module PipelineSteps
  module Webdav
    class Runner < PipelineSteps::RunnerBase
      def initialize(computation, input_data_file_type, options = {})
        super(computation, options)
        @input_data_file_type = input_data_file_type
      end

      protected

      def internal_run
        computation.tap do |c|
          c.update_attributes(input_path: input_data_file.path)
          Rails.logger.info("[RUNNER/WEBDAV][SEGMENTATION] Starting job for: #{c.to_yaml}")
          ::Webdav::StartJob.perform_later(c)
        end
      end

      private

      def input_data_file
        pipeline.data_file(@input_data_file_type)
      end
    end
  end
end
