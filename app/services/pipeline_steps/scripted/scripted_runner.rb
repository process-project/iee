# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

module PipelineSteps
  module Scripted
    class ScriptedRunner < PipelineSteps::Scripted::ScriptedRunnerBase
      protected

      def internal_run
        case computation.deployment
        when 'cluster'
          ::Rimrock::StartJob.perform_later computation if computation.valid?
        when 'cloud'
          ::Cloud::Start.new(computation.user, computation.script).call
          computation.status = 'queued'
          computation.save
        end
      end
    end
  end
end

# rubocop:enable Metrics/AbcSize
