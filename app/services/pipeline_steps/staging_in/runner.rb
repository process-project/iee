# frozen_string_literal: true

module PipelineSteps
  module StagingIn
    class Runner < PipelineSteps::RunnerBase
      def initialize(computation, src_host, src_path,
                     dest_host, dest_path, options = {})
        super(computation, options)
        @src_host = src_host
        @src_path = src_path
        @dest_host = dest_host
        @dest_path = dest_path
      end

      protected

      def internal_run
        computation.tap do |c|
          c.update_attributes(src_host: @src_host,
                              input_path: @src_path,
                              dest_host: @dest_host,
                              output_path: @dest_path)
          ::StagingIn::StartJob.perform_later(c)
        end
      end
    end
  end
end
