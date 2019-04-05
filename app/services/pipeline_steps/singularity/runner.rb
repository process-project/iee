# frozen_string_literal: true

module PipelineSteps
  module Singularity
    class Runner < PipelineSteps::RunnerBase
      def initialize(computation, user_parameters = {}, options = {})
        super(computation, options)

        @user_parameters = eval computation.user_parameters
      end

      protected

      def pre_internal_run
        computation.script = SingularityScriptGenerator.new(
          computation,
          @user_parameters
        ).call
        computation.job_id = nil
      end

      def internal_run
        ::Rimrock::StartJob.perform_later computation if computation.valid?
      end
    end
  end
end
