# frozen_string_literal: true

module PipelineSteps
  module Singularity
    class Runner < PipelineSteps::RunnerBase
      def initialize(computation, options = {})
        super(computation, options)
      end

      protected

      def pre_internal_run
        computation.script = SingularityScriptGenerator.new(computation).call
        computation.job_id = nil
      end

      def internal_run
        ::Rimrock::StartJob.perform_later computation if computation.valid?
      end
    end
  end
end
