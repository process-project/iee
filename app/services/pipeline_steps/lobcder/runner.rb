# frozen_string_literal: true

module PipelineSteps
  module Lobcder
    class Runner < PipelineSteps::RunnerBase
      def initialize(computation, options = {})
        super(computation, options)
      end

      protected

      def internal_run
        ::Lobcder::StartJob.perform_later(computation)
      end
    end
  end
end
