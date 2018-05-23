# frozen_string_literal: true

module PipelineSteps
  module Scripted
    class RimrockRunner < PipelineSteps::Scripted::ScriptedRunnerBase
      protected

      def internal_run
        ::Rimrock::StartJob.perform_later computation if computation.valid?
      end
    end
  end
end
