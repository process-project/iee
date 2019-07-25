# frozen_string_literal: true

module PipelineSteps
  module REST
    class Runner < PipelineSteps::RunnerBase
      def initialize(computation, options = {})
        super(computation, options)
      end

      protected

      def pre_internal_run
        # TODO or maybe 
      end

      def internal_run
        ::REST::StartJob.perform_later computation if computation.valid?
      end
    end
  end
end
