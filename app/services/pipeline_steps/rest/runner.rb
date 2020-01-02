# frozen_string_literal: true

module PipelineSteps
  module Rest
    class Runner < PipelineSteps::RunnerBase
      def initialize(computation, options = {})
        super(computation, options)
      end

      protected

      def pre_internal_run
        computation.job_id = nil
      end

      def internal_run
        ::Rest::StartJob.perform_later computation if computation.valid?
      end
    end
  end
end
