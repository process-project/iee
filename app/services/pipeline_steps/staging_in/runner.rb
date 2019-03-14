# frozen_string_literal: true

module PipelineSteps
  module StagingIn
    class Runner < PipelineSteps::RunnerBase
      def initialize(computation, options = {})
        super(computation, options)
      end

      protected

      def internal_run
        # send post via Reggie API
        computation.tap do |c|
          c.update_attributes(input_path: input_data_file.path)
          ::Webdav::StartJob.perform_later(c)
        end
      end
    end
  end
end