# frozen_string_literal: true

module PipelineSteps
  module Webdav
    class Runner < PipelineSteps::RunnerBase
      def initialize(computation, options = {})
        super(computation, options)
      end

      protected

      def internal_run
        computation.tap do |c|
          c.update_attributes(input_path: image_data_file.path)
          ::Webdav::StartJob.perform_later(c)
        end
      end

      private

      def image_data_file
        pipeline.data_file(:image)
      end

      def input_path
        File.join(@patient.working_dir, "imaging_#{@patient.case_number}.zip")
      end
    end
  end
end
